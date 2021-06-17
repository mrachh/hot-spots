addpath('../src');

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




% solve and visualize the solution

% build double layer potential


p = chebfunpref; p.chebfuneps = 1.0e-13;
p.splitting = 0; p.maxLength=257;

chebabs = [2,5];


assert(checkadjinfo(chnkr) == 0);
refopts = []; refopts.maxchunklen = pi/chebabs(2)/2;
chnkr = chnkr.refine(refopts); chnkr = chnkr.sort();


% plot geometry and data

figure(1)
clf
plot(chnkr,'-b')
hold on
quiver(chnkr,'r')
axis equal


opts = [];

detfun = @(zk) helm_neu_det(zk,chnkr,opts);

detchebs = chebfun(detfun,chebabs,p);
figure(2)
plot(abs(detchebs))