clear;clc;addpath('../src');

run('~/matlab_libs/startup.m');

diary('test_optimization_diary.txt');

num_verts = 100;
num_params = num_verts;



% rnd_sigma = 1e-3;
% init_weight = normrnd(1/sqrt(pi), rnd_sigma, 1, num_params);
% [~, init_weight] = check_convex(init_weight);
% error('nothing')
init_weight_ws = load('init_weight.mat');
init_weight = init_weight_ws.init_weight;

% error('nothing')
% Gradient descent parameter
gd_params = struct( ...
    'maxiter',          100, ...
    'report',           1, ...
    'eps',              1e-7,   ...
    'hspace',           5e-4, ...
    'line_search_eps',  1e-6, ...
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