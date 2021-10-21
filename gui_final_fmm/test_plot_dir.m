addpath('../src');
clear;

% Global parameters
NUM_VERTS = 4;
xlimit = [-3 3];
ylimit = [-3 3];
% TODO: kvec by angle direction

zk = 1;

direction = pi/2;
kvec = zk.*[cos(direction); sin(direction)];
MAX_CHUNK_LEN = 4.0/zk;

% Create the polygon

cparams = [];
cparams.eps = 1.0e-5;
cparams.nover = 0;
cparams.maxchunklen = MAX_CHUNK_LEN;
pref = []; 
pref.k = 16;

vert_angles = 0 : 2*pi/NUM_VERTS : 2*pi;
vert_angles = vert_angles(1:NUM_VERTS);
vert_coords = cat(1, cos(vert_angles), sin(vert_angles));
%[vert_coords,~,~,~] = init_shape(1);

% Create the chunked geometry
chnkr = chunkerpoly(vert_coords, cparams, pref);

assert(checkadjinfo(chnkr) == 0);


refopts = []; refopts.maxchunklen = MAX_CHUNK_LEN;
chnkr = chnkr.refine(); chnkr = chnkr.sort();
figure(1)
plot(chnkr)
disp(chnkr.nch)
start = tic;  [F,invtype] = compute_F(chnkr,zk); t1 = toc(start);
fprintf('%5.2e s : time to compress inverse\n',t1)
rhs = compute_rhs(chnkr,direction,zk);
sol = compute_sol(F,rhs,invtype);


XLO = -3;
XHI = 3;
YLO = -3;
YHI = 3;
NPLOT = 250;

xtarg = linspace(XLO,XHI,NPLOT); 
ytarg = linspace(YLO,YHI,NPLOT);
[xxtarg,yytarg] = meshgrid(xtarg,ytarg);
targets = zeros(2,length(xxtarg(:)));
targets(1,:) = xxtarg(:); targets(2,:) = yytarg(:);

%

out = find_targets(chnkr,targets);

%start = tic; uscat = compute_uscat(chnkr, zk, sol, out, targets); t1 = toc(start);
fprintf('%5.2e s : time to compute ifmm\n',t1)
start = tic; [flag,corr] = get_flags_corr(chnkr,zk,targets(:,out)); t1 = toc(start);
fprintf('%5.2e s : time to compute near correction\n',t1)
start = tic; [flag,corr] = get_flags_corr_fast(chnkr,zk,targets(:,out)); t1 = toc(start);
fprintf('%5.2e s : time to compute near correction\n',t1)

start = tic; uscat = compute_uscat(chnkr,zk,sol,out,targets); t1 = toc(start);
fprintf('%5.2e s : time to compute fmm\n',t1)
start = tic; uscat = compute_uscat_withcorr(chnkr,zk,sol,out,targets,flag,corr); t1 = toc(start);
fprintf('%5.2e s : time to compute fmm\n',t1)
%err = norm(uscat-uscat2)/norm(uscat);
%fprintf('%5.2e : error in withcorr comp\n',err)
figure(1)
clf
ax = gca;
chnk_plot_axis = plot_new(ax, chnkr);
uin = planewave(kvec,targets(:,out));
utot = uscat(:) + uin(:);

hold on
%h = plot_dir(ax, uscat, direction, zk, targets, out, ...
%    xxtarg, yytarg, 'total field', 'log');
%colorbar(ax)
%shg

zztarg = nan(size(xxtarg)) + 1i*nan(size(xxtarg));
zztarg(out) = utot;


figure(2)
clf
plot(chnkr), hold on;

zztarg_plot = log10(abs(zztarg));
%zztarg_plot(zztarg_plot>1e-1) = 1;
h = pcolor(xxtarg,yytarg,zztarg_plot);
set(h,'EdgeColor','none');
colorbar()
hold on;
plot(chnkr,'LineWidth',2)
%quiver(chnkr)