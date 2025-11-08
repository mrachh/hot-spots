clear; clc;
addpath ../src
addpath ../src_shaper_ders/
cluster_startup;

n = 8;
ncheb = 16;
ycenter = 0.97;
amin = 2.0;
bmin = 3.0;
%% init circle
rads  = initialize_circle(n, ycenter);
angles = initialize_angles(n);
verts = compute_polygon_vertices(angles, rads);
[chnkr, nv, tn, ichn] = build_chunker(verts);
%% compute
tobj = tic;
[val, zk, sig, mu, bie_norm, F] = obj_fun_flam(chnkr, tn, ichn, amin, bmin, ncheb);
tobj = tic(tobj);
tgrad = tic(tgrad);
[dvals, dzks] = get_grads_fmm(chnkr, tn, ichn, sig, mu, zk, bie_norm, F, nv);
tgrad = toc(tgrad);
fprintf('tobj: %.2fs| tgrad: %.2fs| ', tobj, tgrad);
