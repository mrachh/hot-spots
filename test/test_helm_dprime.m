clear;
clc;
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

% solve
fkern = @(s,t) chnk.helm2d.kern(zk,s,t,'d',1);
% compute boundary data
srcinfo = []; srcinfo.r = targ0; targinfo = []; targinfo.r = chnkr.r;
targinfo.r = reshape(targinfo.r,2,chnkr.k*chnkr.nch);
targinfo.d = chnkr.d;
targinfo.d = reshape(targinfo.d,2,chnkr.k*chnkr.nch);
rhs = chnk.helm2d.kern(zk,srcinfo,targinfo,'s'); rhs = rhs(:);
dval = -0.5;
opts_flam = []; opts_flam.flamtype = 'rskelf';
F = chunkerflam(chnkr,fkern,dval,opts_flam);
sigma = rskelf_sv(F,rhs);




[dp,varargout] = helm_dprime(zk,chnkr,sigma);
