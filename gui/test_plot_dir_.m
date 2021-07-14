addpath('../src');
clear;


% Global parameters
NUM_VERTS = 4
kvec = 20*[1;-1.5];

%
zk = norm(kvec);
MAX_CHUNK_LEN = 4.0/zk



% discretize domain

cparams = [];
cparams.eps = 1.0e-10;
cparams.nover = 0;
cparams.maxchunklen = 4.0/zk; % setting a chunk length helps when the
                              % frequency is known
                              
pref = []; 
pref.k = 16;
narms =5;
amp = 0.25;

% Create the chunked geometry
vert_angles = 0 : 2*pi/NUM_VERTS : 2*pi;
vert_angles = vert_angles(1:NUM_VERTS);
vert_coords = cat(1, cos(vert_angles), sin(vert_angles));
chnkr = chunkerpoly(vert_coords, cparams, pref);

[~,~,info] = sortinfo(chnkr);
assert(info.ier == 0);

% plot geometry and data

figure(2)
clf
plot(chnkr,'-x')
hold on
quiver(chnkr)
axis equal



% code in demo_scatter.m %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%compute
fkern = @(s,t) chnk.helm2d.kern(zk,s,t,'c',1);
opdims(1) = 1; opdims(2) = 1;
opts = [];
start = tic; sysmat = chunkermat(chnkr,fkern,opts);
t1 = toc(start);

fprintf('%5.2e s : time to assemble matrix\n',t1)

sys = 0.5*eye(chnkr.k*chnkr.nch) + sysmat;

rhs = -planewave(kvec(:),chnkr.r(:,:)); rhs = rhs(:);
start = tic; sol = gmres(sys,rhs,[],1e-13,100); t1 = toc(start);



% evaluate at targets and plot

rmin = min(chnkr); rmax = max(chnkr);
xl = rmax(1)-rmin(1);
yl = rmax(2)-rmin(2);
nplot = 400;
xtarg = linspace(rmin(1)-xl,rmax(1)+xl,nplot); 
ytarg = linspace(rmin(2)-yl,rmax(2)+yl,nplot);
[xxtarg,yytarg] = meshgrid(xtarg,ytarg);
targets = zeros(2,length(xxtarg(:)));
targets(1,:) = xxtarg(:); targets(2,:) = yytarg(:);

%

start = tic; in = chunkerinterior(chnkr,targets); t1 = toc(start);
out = ~in;

fprintf('%5.2e s : time to find points in domain\n',t1)

% compute layer potential based on oversample boundary

start = tic;
uscat = chunkerkerneval(chnkr,fkern,sol,targets(:,out)); t1 = toc(start);
fprintf('%5.2e s : time for kernel eval (for plotting)\n',t1)

uin = planewave(kvec,targets(:,out));
utot = uscat(:)+uin(:);

%

maxin = max(abs(uin(:)));
maxsc = max(abs(uin(:)));
maxtot = max(abs(uin(:)));

maxu = max(max(maxin,maxsc),maxtot);

figure(1)
zztarg = nan(size(xxtarg));
zztarg(out) = utot;
h=pcolor(xxtarg,yytarg,imag(zztarg));
set(h,'EdgeColor','none')
hold on
plot(chnkr,'LineWidth',2)
axis equal
axis tight
colormap(redblue)
caxis([-maxu,maxu])
title('$u_{tot}$','Interpreter','latex','FontSize',24)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


