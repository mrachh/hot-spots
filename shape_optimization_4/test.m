clear;clc;addpath('../src');


diary('poly50_ellipse_gd_diary.txt');

num_verts = 50;
angle_diff = pi/(num_verts - 1);
angles = 0:angle_diff:(pi/2);
a = 1.0;
b = 1.0/2.761451254618413;
normalize = 0.754208196380421;
a = a/normalize;
b = b/normalize;


init_weight = a*b./sqrt((b.*cos(angles)).^2 + (a.*sin(angles)).^2);

% polysymeven_chnk(init_weight,true)

% error('nothing')

cparams = struct( ...
    'maxiter',          100, ...
    'report',           1, ...
    'eps',              1e-6,   ...
    'hspace',           1e-2, ...
    'line_search_eps',  1e-6, ...
    'line_search_beta', 0.5 ...
)

fun = @polysymeven_loss;
fprintf('Polygon half ellipse with %d vertices\n', num_verts);
[opt, gd_log] = optim.gd(fun, init_weight, cparams);
fprintf('optimal weight: %5.2e \n', opt);
fprintf('optimal value: %5.2e \n', fun(opt));
clear fun


diary off;