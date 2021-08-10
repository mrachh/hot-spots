clear;clc;addpath('../src');

diary('diary.txt');

num_verts = 4;
num_params = num_verts /2;

% Set initial weight
% init_weight = ones(1, num_params)/sqrt(pi/2);
init_weight = [0.5 2];

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

fprintf('Polygon symmetric with %d vertices\n', num_verts);

% Start gradient descent
[opt, gd_log] = gd(fun, init_weight, cparams);
fprintf('optimal weight: %5.2e \n', opt);
fprintf('optimal value: %5.2e \n', fun(opt));
clear fun;


diary off;