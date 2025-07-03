addpath('../src');
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
%chnkr = chnkr.refine(); chnkr = chnkr.sort();



% plot geometry and data

figure(1)
clf
plot(chnkr,'-b')
hold on
quiver(chnkr,'r')
axis equal

r = chnkr.r;
x = r(1,:);
y = r(2,:);
x = x(:);
y = y(:);
uval = x + sin(y/10) + 1 + 1j*(cos(2*x) + 3*y);
vval = 4*y + cos(2*x/10) + 1+ 1j*(sin(3*y) + 2*x);


ww = randnfun2(1);
uval = ww(x,y);
ww2 = randnfun2(1);
vval = ww2(x,y);




opts = [];
opts.flam = true;
opts.eps = eps;

detfun = @(zk) helm_dir_det(zk,chnkr,opts);
detfun2 = @(zk) helm_dir_randinv(zk,chnkr,opts);

%detchebs = chebfun(detfun,chebabs,p);
detchebs11 = chebfun(detfun2,chebabs,p);
return

figure(2)
plot(real(detchebs2),'k-'); hold on;
plot(imag(detchebs2),'r-');

figure(3)
clf;
plot(real(detchebs3),'k-'); hold on;
plot(imag(detchebs3),'r-');

figure(4)
clf;
plot(real(detchebs4),'k-'); hold on;
plot(imag(detchebs4),'r-');

figure(5)
clf
plot(real(detchebs5),'k-'); hold on;
plot(imag(detchebs5),'r-');


figure(6)
clf
plot(real(detchebs6),'k-'); hold on;
plot(imag(detchebs6),'r-');

figure(7)
clf
plot(real(detchebs7),'k-'); hold on;
plot(imag(detchebs7),'r-');

figure(8)
clf
plot(real(detchebs8),'k-'); hold on;
plot(imag(detchebs8),'r-');

figure(9)
clf
plot(real(detchebs9),'k-'); hold on;
plot(imag(detchebs9),'r-');

figure(10)
clf
plot(real(detchebs10),'k-'); hold on;
plot(imag(detchebs10),'r-');


figure(11)
clf
plot(real(detchebs11),'k-'); hold on;
plot(imag(detchebs11),'r-');





rts = roots(detchebs,'complex');
rts_real = rts(abs(imag(rts))<eps*10);

rts2 = roots(detchebs2,'complex');
rts2_real = rts2(abs(imag(rts2))<eps*10);

rts3 = roots(detchebs3,'complex');
rts3_real = rts3(abs(imag(rts3))<eps*10);

rts4 = roots(detchebs4,'complex');
rts4_real = rts4(abs(imag(rts4))<eps*10000);


zk = real(rts_real(1));
[d,F] = helm_dir_det(zk,chnkr,opts);
nsys = chnkr.nch*chnkr.k;
xnull = rskelf_nullvec(F,nsys,1,4);
xnrm = norm(xnull,'fro');
xnrm_mv = norm(rskelf_mv(F,xnull),'fro');
err_nullvec = xnrm_mv/xnrm;
fprintf('Error in null vector: %5.2e\n',err_nullvec);

return



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