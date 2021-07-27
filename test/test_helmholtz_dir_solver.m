addpath('../src');
% Set max chunk length
MAX_CHUNK_LEN = 1.0

% Create the unit disk

cparams = [];
cparams.eps = 1.0e-5;
pref = []; 
pref.k = 16;

zk = 1.1 + 0.1*1j;
% modes and center define the unit disk
modes = [1]% [1.0 0 0 0 0 0.3];
ctr = [0.01 0];

% Create source and target location
src0 = [0.3;0.21];
targ0 = [0.7;5.8];

a = 1.1;
b = 2.2;

% Create the chunked geometry
%chnkr = chunkerfunc(@(t) chnk.curves.bymode(t,modes,ctr),cparams,pref);
chnkr = chunkerfunc(@(t) ellipse(t,a,b,ctr),cparams,pref);

assert(checkadjinfo(chnkr) == 0);
refopts = []; refopts.maxchunklen = MAX_CHUNK_LEN;
chnkr = chnkr.refine(refopts); chnkr = chnkr.sort();

% plot geometry and data

figure(1)
clf
plot(chnkr,'-b')
hold on
quiver(chnkr,'r')
axis equal


% solve and visualize the solution

% build double layer potential

fkern = @(s,t) chnk.helm2d.kern(zk,s,t,'D',1);

start = tic; dmat = chunkermat(chnkr,fkern);
t1 = toc(start);

fprintf('%5.2e s : time to assemble matrix\n',t1)

% Everything above is the same as in the neu code

% construct matrix "-I/2 + D"
sys = - 0.5*eye(chnkr.k*chnkr.nch) + dmat;

% get the boundary data for a source located at the point above
targs = chnkr.r; targs = reshape(targs,2,chnkr.k*chnkr.nch);
targstau = tangents(chnkr); 
targstau = reshape(targstau,2,chnkr.k*chnkr.nch);

% compute boundary data
srcinfo = []; srcinfo.r = targ0; targinfo = []; targinfo.r = chnkr.r;
targinfo.r = reshape(targinfo.r,2,chnkr.k*chnkr.nch);
targinfo.d = chnkr.d;
targinfo.d = reshape(targinfo.d,2,chnkr.k*chnkr.nch);
ubdry = chnk.helm2d.kern(zk,srcinfo,targinfo,'s');
dudnbdry = chnk.helm2d.kern(zk,srcinfo,targinfo,'sprime');


% solve linear system to get sigma
rhs = ubdry; rhs = rhs(:);
start = tic; sol = gmres(sys,rhs,[],1e-14,100); t1 = toc(start);

% compute D[sigma](x_in)
targinfo = []; targinfo.r = src0; srcinfo = []; srcinfo.r = chnkr.r;
srcinfo.r = reshape(srcinfo.r,2,chnkr.k*chnkr.nch);
srcinfo.d = chnkr.d;
srcinfo.d = reshape(srcinfo.d,2,chnkr.k*chnkr.nch);
temp = chnk.helm2d.kern(zk,srcinfo,targinfo,'D').';

% compute quadrature weights
ws = weights(chnkr);
ws = reshape(ws,chnkr.k*chnkr.nch, 1);
ucomputed = sum(sol .* temp .* ws);


% compute H_0(k(x_out - x_in))
srcinfo = []; srcinfo.r = src0; targinfo = []; targinfo.r = targ0;
uex = chnk.helm2d.kern(zk,srcinfo,targinfo,'s');

% compute error between the above two quantities
err_gmres =  norm(uex-ucomputed)/norm(uex);


% Now use direct solver to do the same test

% sign of dval flipped for dir problems
dval = -0.5;
opts_flam = [];
opts_flam.flamtype = 'rskelf';

F = chunkerflam(chnkr,fkern,dval,opts_flam);
sol2 = rskelf_sv(F,rhs);

% compute D[sigma](x_in)
srcinfo = []; targinfo.r = src0; srcinfo = []; srcinfo.r = chnkr.r;
srcinfo.r = reshape(srcinfo.r,2,chnkr.k*chnkr.nch);
srcinfo.d = chnkr.d;
srcinfo.d = reshape(srcinfo.d,2,chnkr.k*chnkr.nch);
temp = chnk.helm2d.kern(zk,srcinfo,targinfo,'D').';
ws = weights(chnkr);
ws = reshape(ws,chnkr.k*chnkr.nch, 1);
ucomputed = sum(sol2 .* temp .* ws);

% compute error between the above two quantities
err_fds =  norm(uex-ucomputed)/norm(uex);


dudncomputed = helm_dprime(zk,chnkr,sol2);
err_dudn =  norm(dudnbdry-dudncomputed)/norm(sol2);



% report results
refopts.maxchunklen;
fprintf('Max chunk length: %5.2e\n',refopts.maxchunklen);
fprintf('Error of sol_gmres: %5.2e\n',err_gmres);
fprintf('Error of sol_fds: %5.2e\n',err_fds);
fprintf('Error of sol_dudn: %5.2e\n',err_dudn);

% dudncomputed = helm_dprime(zk,chnkr,sol2);
r = chnkr.r(:);
r = reshape(r,[2,chnkr.k*chnkr.nch]);
wts = weights(chnkr);
wts = reshape(wts,[chnkr.k*chnkr.nch,1]);

rint = sum(dudncomputed.*wts);
rint = rint/abs(rint);
y = real(dudncomputed./rint);


[ymax,iind] = max(y);

ichind = ceil(iind/chnkr.k);
[~,~,u,v] = lege.exps(chnkr.k);
y = reshape(y,[chnkr.k,chnkr.nch]);
ycoefs = u*y(:,ichind);
ydcoefs = lege.derpol(ycoefs);

ccheb = leg2cheb(ycoefs);
p = chebfun(ccheb,'coeffs');

cchebd = leg2cheb(ydcoefs);
pd = chebfun(cchebd,'coeffs');
rr = roots(pd);
yy = p(rr);
[ymax_final,iind] = max(yy);
ymax_loc = rr(iind);

%

figure(3)
plot(p), hold on; plot(rr,p(rr),'.r')
figure(4)
plot(pd), hold on; plot(rr,pd(rr),'.r')

figure(5)
clf
plot(chnkr,'-b')
hold on
xs = reshape(chnkr.r(1,:), chnkr.k * chnkr.nch,1);
ys = reshape(chnkr.r(2,:), chnkr.k * chnkr.nch,1);
zs = reshape(y, chnkr.k * chnkr.nch, 1);
[zmax, zmax_ind] = max(zs);
caxis
scatter(xs, ys, 10, zs, 'filled')
plot(xs(zmax_ind), ys(zmax_ind), '.r','MarkerSize',20)
axis equal