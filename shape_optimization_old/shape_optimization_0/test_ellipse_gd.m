addpath('../src');
clear;
clc;

%
%   Performs gradient descent on ellipse
%

diary('ellipse_gd_diary.txt');

cparams = struct( ...
    'maxiter',          100, ...
    'report',           1, ...
    'eps',              1e-4,   ...
    'hspace',           1e-2, ...
    'line_search_eps',  1e-6, ...
    'line_search_beta', 0.5 ...
)


init_weight = 1.1;
fun = @ellipse_loss;
fprintf('Ellipse: \n');
[opt, gd_log] = optim.gd_1d(fun, init_weight, cparams);
fprintf('optimal weight: %5.2e \n', opt);
fprintf('optimal value: %5.2e \n', fun(opt));
clear fun



diary off;