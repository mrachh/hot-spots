addpath('../src');
clear;

% Global parameters
NUM_VERTS = 5;
xlimit = [-3 3];
ylimit = [-3 3];
% TODO: kvec by angle direction
kvec = 2;
zk = 36;
MAX_CHUNK_LEN = 4.0/zk;

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

figure(1)
clf
plot(chnkr,'-x')
hold on
quiver(chnkr)
axis equal
hold on
ax = gca
sol = plot_dir(ax, chnkr, zk, kvec, xlimit, ylimit)
shg