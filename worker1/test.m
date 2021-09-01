clear;clc;addpath('../src');

diary('test_optimization_diary.txt');

num_verts = 20;
num_params = num_verts;



init_weight = ones(1,num_verts)/sqrt(pi);

% Last time:
% [0.408066774854523 0.429040642463146 1.18253139126812 0.65423897111139 0.443338318926292 0.440662202602962 0.639294305380822 1.15659966820638]

% init_weight = [0.408066774854523 0.429040642463146 1.18253139126812 0.65423897111139 0.443338318926292 0.440662202602962 0.839294305380822 1.15659966820638];

% plot(chnk_poly(init_weight))
% error('nothing')


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