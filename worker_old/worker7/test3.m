clear;clc;addpath('../src');

run('~/matlab_libs/startup.m');

tic

diary('test_optimization_diary.txt');

num_verts = 10;
num_params = num_verts;



% rnd_sigma = 1e-3;
% init_weight = normrnd(1/sqrt(pi), rnd_sigma, 1, num_params);
% [~, init_weight] = check_convex(init_weight);
% error('nothing')

% init_weight = [0.563945298879718   0.564851815720133   0.564865732303110   0.563513505876953   0.564424234906898   0.566401525432045   0.563926851865282   0.564268141749132   0.564365857909443   0.563353533483639];

init_weight = [0.386927796313667   0.918276960009773   2.143462283971090   1.324705903529868   1.324689438671268 2.143349432151309   0.918265938669922   0.386170218465028   0.257781815405923   0.255308857223825];
% Gradient descent parameter
gd_params = struct( ...
    'maxiter',          100, ...
    'report',           1, ...
    'eps',              1e-7,   ...
    'hspace',           1e-4, ...
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

toc


diary off;