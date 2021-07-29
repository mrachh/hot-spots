addpath('../src');
clear;

cparams = struct( ...
    'maxiter',          60, ...
    'report',           20, ...
    'eps',              1e-4,   ...
    'hspace',           1e-7, ...
    'line_search_eps',  1e-6, ...
    'line_search_beta', 0.7 ...
);


init = 3;
fun = @optim.tests.quad_fun;
fprintf('TEST1: quadratic test function\n');
[opt, gd_log] = optim.gd(fun, init, cparams);
fprintf('optimal weight: %5.2e \n', opt);
fprintf('optimal value: %5.2e \n', fun(opt));
clear fun


init = 1.4;
fun = @optim.tests.test1;
fprintf('TEST2: x^4-2x^2+1 initialized near optima 1\n');
[opt, gd_log] = optim.gd(fun, init, cparams);
fprintf('optimal weight: %5.2e \n', opt);
fprintf('optimal value: %5.2e \n', fun(opt));
clear fun

init = 3;
fun = @optim.tests.test1;
fprintf('TEST3: x^4-2x^2+1 initialized far from optima 1\n');
[opt, gd_log] = optim.gd(fun, init, cparams);
fprintf('optimal weight: %5.2e \n', opt);
fprintf('optimal value: %5.2e \n', fun(opt));
clear fun

init = [2 3];
fun = @optim.tests.test2;
fprintf('TEST4: quadratic form A = [1 0; 0 1], b = 0\n');
[opt, gd_log] = optim.gd(fun, init, cparams);
disp(opt)
fprintf('optimal value: %5.2e \n', fun(opt));
clear fun

init = [2 3];
fun = @optim.tests.test3;
fprintf('TEST5: quadratic form A = [2 0; 0 3], b = 0\n');
[opt, gd_log] = optim.gd(fun, init, cparams);
disp(opt)
fprintf('optimal value: %5.2e \n', fun(opt));
clear fun