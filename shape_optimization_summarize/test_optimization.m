clear;clc;addpath('../src');

diary('diary_6gon.txt');

num_verts = 6;
num_params = num_verts /2;

% Set initial weight
angle_diff = pi/(num_verts - 1);
angles = 0:angle_diff:(pi/2);
init_weight = 1-((angles-(pi/2)).^2)./10;
% init_weight = [0.5 sqrt(7/4) sqrt(3.25)]/sqrt(pi);
% chnkr = polysymeven_chnk(init_weight, true)
% plot(chnkr)
% xlim([-2 2])
% ylim([-2 2])


% Gradient descent parameter
cparams = struct( ...
    'maxiter',          100, ...
    'report',           1, ...
    'eps',              1e-6,   ...
    'hspace',           1e-2, ...
    'line_search_eps',  1e-6, ...
    'line_search_beta', 0.5 ...
)

% Set loss function
fun = @polysymeven_loss;

fprintf('Polygon polygon with %d vertices\n', num_verts);
[opt, gd_log] = gd(fun, init_weight, cparams);
fprintf('optimal weight: %5.2e \n', opt);
fprintf('optimal value: %5.2e \n', fun(opt));
clear fun


diary off;