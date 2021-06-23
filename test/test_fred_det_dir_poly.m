addpath('../src');
clear;

% Global parameters
MAX_CHUNK_LEN = 1
NUM_VERTS = 5


% Create polygon

cparams = [];
cparams.eps = 1.0e-5;
pref = []; 
pref.k = 16;

% Create source and target location
src0 = [0.3;0.21];
targ0 = [0.7;1.8];

% Create the chunked geometry
ctr = [0 0];
modes = 1
vert_angles = 0 : 2*pi/NUM_VERTS : 2*pi
vert_angles = vert_angles(1:NUM_VERTS)
vert_coords = ctr.' + modes .* cat(1, cos(vert_angles), sin(vert_angles))
chnkr = chunkerpoly(vert_coords, cparams, pref);



% solve and visualize the solution

% build double layer potential


eps = 1e-7;
p = chebfunpref; p.chebfuneps = eps;
p.splitting = 0; p.maxLength=257;

chebabs = [2,5];


assert(checkadjinfo(chnkr) == 0);
refopts = []; refopts.maxchunklen = pi/chebabs(2)/2;
chnkr = chnkr.refine(refopts); chnkr = chnkr.sort();


% plot geometry and data

figure(1)
clf
plot(chnkr,'-b')
hold on
quiver(chnkr,'r')
axis equal


opts = [];
opts.flam = true;
opts.eps = eps;

detfun = @(zk) helm_dir_det(zk,chnkr,opts);

detchebs = chebfun(detfun,chebabs,p);
figure(2)
plot(abs(detchebs))

rts = roots(detchebs,'complex');
rts_real = rts(abs(imag(rts))<eps*10);

zk = real(rts_real(1));
[d,F] = helm_dir_det(zk,chnkr,opts);
nsys = chnkr.nch*chnkr.k;
xnull = rskelf_nullvec(F,nsys,1,4);
xnrm = norm(xnull,'fro');
xnrm_mv = norm(rskelf_mv(F,xnull),'fro');
err_nullvec = xnrm_mv/xnrm;
fprintf('Error in null vector: %5.2e\n',err_nullvec);



% evaluate at targets and plot

rmin = min(chnkr); rmax = max(chnkr);
nplot = 200;
hx = (rmax(1)-rmin(1))/nplot;
hy = (rmax(2)-rmin(2))/nplot;
xtarg = linspace(rmin(1)+hx/2,rmax(1)-hx/2,nplot); 
ytarg = linspace(rmin(2)+hy/2,rmax(2)-hy/2,nplot);
[xxtarg,yytarg] = meshgrid(xtarg,ytarg);
targets = zeros(2,length(xxtarg(:)));
targets(1,:) = xxtarg(:); targets(2,:) = yytarg(:);

start = tic; in = chunkerinterior(chnkr,targets); t1 = toc(start);
fprintf('%5.2e s : time to find points in domain\n',t1)

% compute layer potential at interior points
fkern = @(s,t) chnk.helm2d.kern(zk,s,t,'D',1);
start = tic;
Dsol = chunkerkerneval(chnkr,fkern,xnull,targets(:,in)); t1 = toc(start);
fprintf('%5.2e s : time for kerneval (adaptive for near)\n',t1);

% 

figure(3)
clf
zztarg = nan(size(xxtarg));
zztarg(in) = real(Dsol);
h=surf(xxtarg,yytarg,zztarg);
set(h,'EdgeColor','none')

% compare to analytic value (WIP)