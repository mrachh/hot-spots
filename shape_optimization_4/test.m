clear;clc;addpath('../src');


diary('poly50_ellipse_gd_diary.txt');

num_verts = 40;
angle_diff = pi/(num_verts - 1);
angles = 0:angle_diff:(pi/2);
a = 1.0;
b = 1.0/2.761451254618413;
normalize = 0.754208196380421;
a = a/normalize;
b = b/normalize;


init_weight = a*b./sqrt((b.*cos(angles)).^2 + (a.*sin(angles)).^2);

% weight
1.325893837801256
1.298336970174506
1.225533307642555
1.128895852810748
1.027729786068687
0.933370595677264
0.850400691193793
0.779582773159788
0.720007128148762
0.670234126594522
0.628802508456938
0.594418668945795
0.566004323415139
0.542688141192842
0.523779292741415
0.508738538921712
0.497152632933519
0.488713675059795
0.483203466466474
0.480482403958544

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