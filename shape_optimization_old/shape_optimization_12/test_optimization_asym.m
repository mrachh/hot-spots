clear;clc;addpath('../src');

diary('test_optimization_asym_diary.txt');

num_verts = 6;
num_params = num_verts /2;


% angle_diff = pi/(num_verts - 1);
% angles = 0:angle_diff:(pi/2);
% init_weight = 1-((angles-(pi/2)).^2)./10;
init_weight = [
    0.753259889972766   
    0.911173560390196   
    0.990130395598911
    0.890130395598911
    0.811173560390196 
    0.653259889972766 
]';
% plot(chnk_poly(init_weight))
% error('nothing')
% Gradient descent parameter
gd_params = struct( ...
    'maxiter',          100, ...
    'report',           1, ...
    'eps',              1e-6,   ...
    'hspace',           1e-3, ...
    'line_search_eps',  1e-4, ...
    'line_search_beta', 0.5, ...
    'savefn',           'gd_asym.mat' ...
)

loss_params = struct(...
    'default_chebabs',      [1 10], ...
    'chnk_fun',             @chnk_poly, ...
    'udnorm_ord',              'inf', ...
    'unorm_ord',                  '2', ...
    'vert_type',             'full' ...
)

% Set loss function
fun = @loss;

fprintf('Polygon polygon with %d vertices\n', num_verts);
[opt, gd_log] = gd(@loss, init_weight, gd_params, loss_params);
fprintf('optimal weight: %5.2e \n', opt);
fprintf('optimal value: %5.2e \n', fun(opt));
clear fun


diary off;