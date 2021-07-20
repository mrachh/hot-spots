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
NPLOT = 400;

xtarg = linspace(XLO,XHI,NPLOT); 
ytarg = linspace(YLO,YHI,NPLOT);
[xxtarg,yytarg] = meshgrid(xtarg,ytarg);
targets = zeros(2,length(xxtarg(:)));
targets(1,:) = xxtarg(:); targets(2,:) = yytarg(:);

%

out = find_targets(chnkr,targets);
start = tic; in2 = chunkerinterior_fmm(chnkr,targets); t1 = toc(start);
out2 = ~in2;
err = norm(out-out2);
fprintf('%5.2e s : time to find points in domain faster\n',t1);
fprintf('%5.2e s : error between slow and fast routine\n',err);

out_plot = int8(reshape(out, NPLOT, NPLOT));
pcolor(xtarg,ytarg,out_plot); hold on;
plot(chnkr)
