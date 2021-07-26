addpath('../src');
clear;

% Global parameters
NUM_VERTS = 5;
xlimit = [-3 3];
ylimit = [-3 3];
% TODO: kvec by angle direction
direction = 2;
k = 36;
MAX_CHUNK_LEN = 1;

% Create the polygon

cparams = [];
cparams.eps = 1.0e-5;
cparams.nover = 0;
cparams.maxchunklen = MAX_CHUNK_LEN;
pref = []; 
pref.k = 16;

vert_angles = 0 : 2*pi/NUM_VERTS : 2*pi
vert_angles = vert_angles(1:NUM_VERTS)
vert_coords = cat(1, cos(vert_angles), sin(vert_angles))

% Create the chunked geometry
chnkr = chunkerpoly(vert_coords, cparams, pref);

assert(checkadjinfo(chnkr) == 0);
refopts = []; refopts.maxchunklen = MAX_CHUNK_LEN;
chnkr = chnkr.refine(refopts); chnkr = chnkr.sort();

% TODO: kvec by angle direction
kvec = k .* [cos(direction); sin(direction)];
zk = k


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% preparation
fkern = @(s,t) chnk.helm2d.kern(zk,s,t,'c',1);
opdims(1) = 1; opdims(2) = 1;
opts = [];
start = tic; sysmat = chunkermat(chnkr,fkern,opts);
t1 = toc(start);
sys = 0.5*eye(chnkr.k*chnkr.nch) + sysmat;
rhs = -planewave(kvec(:),chnkr.r(:,:)); rhs = rhs(:);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%fds
dval = 0.5;
opts_flam = [];
opts_flam.flamtype = 'rskelf';
F = chunkerflam(chnkr,fkern,dval,opts_flam);
start = tic; sol1 = rskelf_sv(F,rhs); t_fds = toc(start);
%%%%%%%%%%%%%%%%%%
% gmres
start = tic; sol2 = gmres(sys,rhs,[],1e-13,100); t_gmres = toc(start);
%%%%%%%%%%%%%%%%%%
% backslash
start = tic; sol3 = sys\rhs; t_bs = toc(start);

fprintf('%d : number of points\n', chnkr.nch)
fprintf('%5.2e s : fds\n',t_fds)
fprintf('%5.2e s : gmres\n',t_gmres)
fprintf('%5.2e s : bs\n',t_bs)