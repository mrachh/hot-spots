n = 16;
init_rads = ones(1,n);
init_angles = initialize_angles(n);
max_iter = 1000;
min_step_size = 1e-8;
maxchunklen = 0.1;
% change this
dump_dir = sprintf('/home/zw395/so0810/gd_ellipse%d',dump_idx);
mean_rads = 1;
init_chebabs = [1 8];
step_size_lower_bound = 1e-3;
h = 1e-2;
quadratic_penalty_factor = 1;
result = gd(dump_dir, h,min_step_size,max_iter,init_angles,init_rads,init_chebabs, maxchunklen, mean_rads, quadratic_penalty_factor, step_size_lower_bound);
