% Create the unit disk

cparams = [];
cparams.eps = 1.0e-5;
pref = []; 
pref.k = 16;

zk = 1.1 + 0.1*1j;
% modes and center define the unit disk
modes = 1;
ctr = [0 0];

% Create source and target location
src0 = [0.3;0.21];
targ0 = [0.7;1.8];

% Create the chunked geometry
chnkr = chunkerfunc(@(t) chnk.curves.bymode(t,modes,ctr),cparams,pref);


assert(checkadjinfo(chnkr) == 0);
refopts = []; refopts.maxchunklen = 0.0625;
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

% Everything above is the same as the neu code

% construct matrix "-I/2 + D"
sys = - 0.5*eye(chnkr.k*chnkr.nch) + dmat;

% get the boundary data for a source located at the point above

kerns = @(s,t) chnk.helm2d.kern(zk,s,t,'s');
smat = chunkermat(chnkr,kerns);

targs = chnkr.r; targs = reshape(targs,2,chnkr.k*chnkr.nch);
targstau = tangents(chnkr); 
targstau = reshape(targstau,2,chnkr.k*chnkr.nch);

% compute boundary data
srcinfo = []; srcinfo.r = targ0; targinfo = []; targinfo.r = chnkr.r;
targinfo.r = reshape(targinfo.r,2,chnkr.k*chnkr.nch);
targinfo.d = chnkr.d;
targinfo.d = reshape(targinfo.d,2,chnkr.k*chnkr.nch);
ubdry = chnk.helm2d.kern(zk,srcinfo,targinfo,'s');

% solve linear system to get sigma
rhs = ubdry; rhs = rhs(:);
start = tic; sol = gmres(sys,rhs,[],1e-14,100); t1 = toc(start);

% compute D[sigma](x_in) (chunker weight missing...)
srcinfo = []; srcinfo.r = src0; targinfo = []; targinfo.r = chnkr.r;
targinfo.r = reshape(targinfo.r,2,chnkr.k*chnkr.nch);
targinfo.d = chnkr.d;
targinfo.d = reshape(targinfo.d,2,chnkr.k*chnkr.nch);
temp = chnk.helm2d.kern(zk,srcinfo,targinfo,'sprime')
ucomputed = sum(sol .* temp)

% compute H_0(k(x_out - x_in))
srcinfo = []; srcinfo.r = src0; targinfo = []; targinfo.r = targ0;
uex = chnk.helm2d.kern(zk,srcinfo,targinfo,'s');

% compute error between the above two quantities
err=  norm(uex-ucomputed)/norm(uex);
fprintf('Error in solution (chunker weights missing): %5.2e\n',err);


% Now use direct solver to do the same test

% sign of dval flipped for dir problems
dval = -0.5;
opts_flam = [];
opts_flam.flamtype = 'rskelf';

F = chunkerflam(chnkr,fkern,dval,opts_flam);
sol2 = rskelf_sv(F,rhs);
err = norm(sol2 - sol) / norm(sol)

fprintf('Error between sol_gmres and sol_fds: %5.2e\n',err);


