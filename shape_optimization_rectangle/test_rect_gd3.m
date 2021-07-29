addpath('../src');
clear;
clc;

diary('rect_gd3.txt');

cparams = struct( ...
    'maxiter',          60, ...
    'report',           1, ...
    'eps',              1e-3,   ...
    'hspace',           1e-4, ...
    'line_search_eps',  1e-6, ...
    'line_search_beta', 0.5 ...
)

init = 1.1;
fun = @optim.tests.test4;
fprintf('TEST: true rectangle objective\n');
[opt, gd_log] = optim.gd_1d(fun, init, cparams);
fprintf('optimal weight: %5.2e \n', opt);
fprintf('optimal value: %5.2e \n', fun(opt));
clear fun

init_weight = 1.1;
fun = @rect_loss;
fprintf('Now we do the actual optimization\n');
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