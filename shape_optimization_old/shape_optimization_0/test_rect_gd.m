addpath('../src');
clear;
clc;

%
%   Performs gradient descent on rectangle
%

diary('rect_gd_diary.txt');

cparams = struct( ...
    'maxiter',          100, ...
    'report',           1, ...
    'eps',              1e-4,   ...
    'hspace',           1e-2, ...
    'line_search_eps',  1e-6, ...
    'line_search_beta', 0.5 ...
)

init = 1.1;
fun = @rect_true_loss;
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


diary off;