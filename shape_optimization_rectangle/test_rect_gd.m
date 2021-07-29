addpath('../src');
clear;
clc;

diary on;

cparams = struct( ...
    'maxiter',          50, ...
    'report',           1, ...
    'eps',              1e-3,   ...
    'hspace',           1e-5, ...
    'line_search_eps',  1e-5, ...
    'line_search_beta', 0.7 ...
);


init_weight = 1.1;
fun = @rect_loss;
[opt, gd_log] = optim.gd_1d(fun, init_weight, cparams);
fprintf('optimal weight: %5.2e \n', opt);
fprintf('optimal value: %5.2e \n', fun(opt));
clear fun


% TODO:

% TODO: 
% gradient descent
% first deriv: 2
% use second deri: 3

diary off;