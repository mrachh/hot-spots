addpath('../src');

% Global parameters
MAX_CHUNK_LEN = 1
NUM_VERTS = 4


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
modes = 1;
vert_angles = 0 : 2*pi/NUM_VERTS : 2*pi;
vert_angles = vert_angles(1:NUM_VERTS);
vert_coords = ctr.' + modes .* cat(1, cos(vert_angles), sin(vert_angles));
chnkr = chunkerpoly(vert_coords, cparams, pref);

%

XLO = -3;
XHI = 3;
YLO = -3;
YHI = 3;
NPLOT = 250;

xtarg = linspace(XLO,XHI,NPLOT); 
ytarg = linspace(YLO,YHI,NPLOT);
[xxtarg,yytarg] = meshgrid(xtarg,ytarg);
targets = zeros(2,length(xxtarg(:)));
targets(1,:) = xxtarg(:); targets(2,:) = yytarg(:);

%

out = find_targets(chnkr)
pcolor(reshape(out, NPLOT, NPLOT))