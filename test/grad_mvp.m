clear; clc;
addpath ../src
addpath ../src_shaper_ders/
%% replace with your startup to load necessary libs (chunkie etc.)
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
%% chunk
tchunk = tic;
[chnkr, nv, tn, ichn] = build_chunker(verts);
tchunk = toc(tchunk);
%% compute
tobj = tic;
[val, zk, sig, mu, bie_norm, F] = obj_fun_flam(chnkr, tn, ichn, amin, bmin, ncheb);
tobj = toc(tobj);
tgrad = tic;
[dvals, dzks] = get_grads_fmm(chnkr, tn, ichn, sig, mu, zk, bie_norm, F, nv);
tgrad = toc(tgrad);
ttotal = tobj+tgrad+tchunk;
fprintf('chunk : %.2fs| objective : %.2fs| gradient : %.2fs| total : %.2fs', tchunk, tobj, tgrad, ttotal);
