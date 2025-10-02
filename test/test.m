clearvars; close all;

% addpath ../src
addpath ../archive/src
addpath ../src_shaper_ders/
cluster_startup;

rx = 1; ry_ratio = 1.5; cy_ratio = 0.5; cx = 0.1; n = 8;
ry = rx*ry_ratio; cy = cy_ratio*ry;
init_rads   = initialize_ellipse(rx,ry,cx,cy,n);
init_rads   = init_rads/mean(init_rads);
init_angles = initialize_angles(n);
verts       = compute_polygon_vertices(init_angles, init_rads);

amin = 2; bmin = 4; ncheb = 32;

t1 = tic;
[val, ~, zk, ~] = compute_obj_and_grads(verts, amin, bmin, ncheb, false);
t1obj = toc(t1);
fprintf('Time (objective only)  = %.6f sec\n', t1obj);

t2 = tic;
[val2, dvals, zk2, dzks] = compute_obj_and_grads(verts, amin, bmin, ncheb, true);
t2grad = toc(t2);
fprintf('Time (objective+grad)  = %.6f sec\n', t2grad);

fprintf('val        = %.12e\n', val);
fprintf('zk         = %.12e\n', zk);
fprintf('val (grad) = %.12e\n', val2);
fprintf('zk  (grad) = %.12e\n', zk2);
fprintf('norm(dvals)= %.12e\n', norm(dvals));

drads = cartesian_to_radial(dvals, init_angles);
fprintf('radial derivatives:\n');
disp(drads);
    