% Global parameters
MAX_CHUNK_LEN = 1
NUM_VERTS = 3

% Create the polygon

cparams = [];
cparams.eps = 1.0e-5;
pref = []; 
pref.k = 16;

zk = 1.1 + 0.1*1j;
% modes and center of polygon
ctr = [0 0];
modes = 1
vert_angles = 0 : 2*pi/NUM_VERTS : 2*pi
vert_angles = vert_angles(1:NUM_VERTS)
vert_coords = ctr.' + modes .* cat(1, cos(vert_angles), sin(vert_angles))


% Create source and target location
src0 = [0.3;0.21];
targ0 = [0.7;1.8];

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