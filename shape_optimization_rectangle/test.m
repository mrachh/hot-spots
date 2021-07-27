addpath('../src');
clear;


verts = [
    0 1 1 0;
    0 0 1 1;
];

xy_s = sum(verts,2)/length(verts);


cparams = []; cparams.eps = 1.0e-5;
pref = []; pref.k = 16;
% Create the chunked geometry
chnkr = chunkerfunc(@(t) chnk.curves.bymode(t,1,xy_s),cparams,pref);
assert(checkadjinfo(chnkr) == 0);
refopts = []; refopts.maxchunklen = pi/5/2;
chnkr = chnkr.refine(refopts); chnkr = chnkr.sort();



k = 32
[xang,yang,wtot] = get_chunkie_quads(chnkr,k,xy_s)


figure(1)
clf
scatter(xang, yang)