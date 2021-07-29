addpath('../src');
clear;
clc;

diary('ellipse_gd2.txt');

cparams = struct( ...
    'maxiter',          60, ...
    'report',           1, ...
    'eps',              1e-2,   ...
    'hspace',           1e-3, ...
    'line_search_eps',  1e-6, ...
    'line_search_beta', 0.7 ...
);


init_weight = 1.1;
fun = @ellipse_loss;
fprintf('Now we do the actual optimization\n');
[opt, gd_log] = optim.gd_1d(fun, init_weight, cparams);
fprintf('optimal weight: %5.2e \n', opt);
fprintf('optimal value: %5.2e \n', fun(opt));
clear fun



diary off;