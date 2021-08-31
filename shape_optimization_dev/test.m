clear;clc;addpath('../src');

diary('test_optimization_diary.txt');

num_verts = 8;
num_params = num_verts;



init_weight = ones(1,num_verts)/sqrt(pi);


% valid_verts = ones(1, num_params);
% plot(chnk_polyeven(init_weight, valid_verts))
% error('nothing')
% Gradient descent parameter
gd_params = struct( ...
    'maxiter',          100, ...
    'report',           1, ...
    'eps',              1e-6,   ...
    'hspace',           1e-3, ...
    'line_search_eps',  1e-4, ...
    'line_search_beta', 0.5, ...
    'savefn',           'gd.mat' ...
)

loss_params = struct(...
    'default_chebabs',      [1 10], ...
    'chnk_fun',             @chnk_poly, ...
    'udnorm_ord',              'inf', ...
    'unorm_ord',                  '2' ...
)

% Set loss function
fun = @loss;

fprintf('Polygon polygon with %d vertices\n', num_verts);
[opt, gd_log] = gd(@loss, init_weight, gd_params, loss_params);
fprintf('optimal weight: %5.2e \n', opt);
fprintf('optimal value: %5.2e \n', fun(opt));
clear fun


diary off;