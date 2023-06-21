n = 8;
bottom = 0.3;
a = 1;
b = 1.5;
h = 1e-3;
min_step_size = 1e-6;
max_iter = 10000;
currentDir = pwd;
parentDir = fileparts(currentDir);
cd(parentDir);
startup
dump_dir = '~/shape_optimization_results/debug/result';
[vertices, angles, rads] = initialize_polygon_vertices(n,bottom,a,b);
rads = load('~/shape_optimization_results/gd8/2.mat',"rads").rads;
vertices = compute_polygon_vertices(angles, rads);


result = 1;
if ~isfolder(dump_dir)
    mkdir(dump_dir);
end
[vertices, angles, rads] = initialize_polygon_vertices(n,bottom,a,b);
% load buggy state
rads = load('~/shape_optimization_results/gd8/2.mat',"rads").rads;
loss_params = struct(...
'default_chebabs',      [1 10], ...
'udnorm_ord',              'inf', ...
'unorm_ord',                  '2' ...
);
[loss, chebabs, zk] = compute_loss(vertices, loss_params, [1 10]);
min_step_size_reached = false;
max_iter_reached = false;
not_converged = true;
iter_idx = 0;

iter_idx = iter_idx + 1;
iter_idx
[f_zero, chebabs, zk] = compute_loss(vertices, loss_params, chebabs);
grad = zeros(1,n);
for rad_index = 1:n 
    h_vector = zeros(1,n);
    h_vector(rad_index) = h;
    f_plus = compute_loss(compute_polygon_vertices(angles, rads+h_vector),loss_params,chebabs);
    f_minus = compute_loss(compute_polygon_vertices(angles, rads-h_vector),loss_params,chebabs);
    grad(rad_index) = (f_plus - f_minus)/(2*h);
end
f_plus = compute_loss(compute_polygon_vertices(angles, rads+h*grad),loss_params,chebabs);
f_minus = compute_loss(compute_polygon_vertices(angles, rads-h*grad),loss_params,chebabs);
% newton on gradient direction to find step size
step = 0.5*h*(f_plus-f_minus)/(f_plus+f_minus-2*f_zero);
if step < 0
    step = 1.0;
end
not_improving = true;

cd(currentDir);