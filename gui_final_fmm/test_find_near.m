clear
clc
load('test1.mat')
load('verts.mat')
cparams = [];
cparams.rounded = true;
pref    = [];
pref.k  = 16;
edgevals = [];
verts = flipud(verts);
chnkr = chunkerpoly(verts',cparams,pref,edgevals);
figure(1)
plot(chnkr), hold on; plot(targets0(1,:),targets0(2,:),'ko')
out0 = chunkerinterior(chnkr,targets0);
out = chunkerinterior_fmm(chnkr,targets0);


