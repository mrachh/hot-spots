addpath('../src');

% Global parameters
MAX_CHUNK_LEN = .25
NUM_VERTS = 3

% Create the polygon
cparams = [];
cparams.eps = 1.0e-5;
pref = []; 
pref.k = 16;
% wave number
zk = 1.1 + 0.1*1j;
% Orientation of polygon
vert_coords = flipud(nsidedpoly(NUM_VERTS).Vertices)'
% Create source and target location
src0 = [0.1;0.1];
targ0 = [1.0;1.8];
% Create the chunked geometry
chnkr = chunkerpoly(vert_coords, cparams, pref);
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

fkern = @(s,t) chnk.helm2d.kern(zk,s,t,'d',1);
start = tic; dmat = chunkermat(chnkr,fkern);
t1 = toc(start);
fprintf('%5.2e s : time to assemble matrix\n',t1)

% Everything above is the same as in the neu code

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

% compute D[sigma](x_in)
targinfo = []; targinfo.r = src0; srcinfo = []; srcinfo.r = chnkr.r;
srcinfo.r = reshape(srcinfo.r,2,chnkr.k*chnkr.nch);
srcinfo.d = chnkr.d;
srcinfo.d = reshape(srcinfo.d,2,chnkr.k*chnkr.nch);
temp = chnk.helm2d.kern(zk,srcinfo,targinfo,'d').'

% compute quadrature weights
ws = weights(chnkr)
ws = reshape(ws,chnkr.k*chnkr.nch, 1)
ucomputed = sum(sol .* temp .* ws)

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
srcinfo = []; srcinfo.r = src0; targinfo = []; targinfo.r = chnkr.r;
targinfo.r = reshape(targinfo.r,2,chnkr.k*chnkr.nch);
targinfo.d = chnkr.d;
targinfo.d = reshape(targinfo.d,2,chnkr.k*chnkr.nch);
temp = chnk.helm2d.kern(zk,srcinfo,targinfo,'sprime')
ws = weights(chnkr)
ws = reshape(ws,chnkr.k*chnkr.nch, 1)
ucomputed = sum(sol2 .* temp .* ws)

% compute error between the above two quantities
err_fds =  norm(uex-ucomputed)/norm(uex);




% report results
refopts.maxchunklen
fprintf('Max chunk length: %5.2e\n',refopts.maxchunklen);
fprintf('Error of sol_gmres: %5.2e\n',err_gmres);
fprintf('Error og sol_fds: %5.2e\n',err_fds);


