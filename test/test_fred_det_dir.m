addpath('../src');
clear;
% Create the unit disk

cparams = [];
cparams.eps = 1.0e-5;
pref = []; 
pref.k = 16;

% modes and center define the unit disk
modes = 1;
ctr = [0 0];

% Create source and target location
src0 = [0.3;0.21];
targ0 = [0.7;1.8];

% Create the chunked geometry
chnkr = chunkerfunc(@(t) chnk.curves.bymode(t,modes,ctr),cparams,pref);




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
fkern = @(s,t) chnk.helm2d.kern(zk,s,t,'d',1);
start = tic;
Dsol = chunkerkerneval(chnkr,fkern,xnull,targets(:,in)); t1 = toc(start);
fprintf('%5.2e s : time for kerneval (adaptive for near)\n',t1);

% 

figure(3)
clf
zztarg = nan(size(xxtarg));
zztarg(in) = abs(Dsol);
h=surf(xxtarg,yytarg,zztarg);
set(h,'EdgeColor','none')

% END OF COMPUTATION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%






% compare to analytic values

fprintf('check1: eigenvalue is a root of bessel function J_0(z_k): %5.2e\n', besselj(0, zk));



% CHECK 1
% verify eigen function on point (37,51) via fd
xpos = 117; ypos = 141;
dx2 = (-zztarg(xpos-2, ypos)/12 + 4*zztarg(xpos-1, ypos)/3 - 5*zztarg(xpos, ypos)/2 ...
        + 4*zztarg(xpos+1, ypos)/3 - zztarg(xpos+2, ypos)/12)/(hx^2);
dy2 = (-zztarg(xpos, ypos-2)/12 + 4*zztarg(xpos, ypos-1)/3 - 5*zztarg(xpos, ypos)/2 ...
        + 4*zztarg(xpos, ypos+1)/3 - zztarg(xpos, ypos+2)/12)/(hy^2);
xylap = dx2 + dy2
err = abs(xylap + zk^2 * zztarg(xpos, ypos));
fprintf('check2: eigenfunction (finite diff) error at (117, 141) of meshgrid: %5.2e\n', err)



% CHECK 2
% verify eigenfunction by analytical expression

figure(4)
clf
zztarg2 = nan(size(xxtarg));
true_eigenfunc = besselj(0, abs(xxtarg(in) + 1j*yytarg(in))*zk)
zztarg2(in) = true_eigenfunc
eigen_func_scale = zztarg(117, 141)/zztarg2(117, 141)
err = zztarg2 * eigen_func_scale - zztarg;
h=surf(xxtarg,yytarg, err);
set(h,'EdgeColor','none')