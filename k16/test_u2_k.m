clear; clc; addpath('../src');

%
%   Tests different ks for integrating \|u\|_2
%

num_verts = 4;

diary('k16.txt');

cparams = struct( ...
    'maxiter',          100, ...
    'report',           1, ...
    'eps',              1e-6,   ...
    'hspace',           1e-2, ...
    'line_search_eps',  1e-6, ...
    'line_search_beta', 0.5 ...
)


init_weight = [0.5 1];
loss1 = polysymeven_loss(init_weight);
init_weight = [1 1]/sqrt(pi/2);
loss2 = polysymeven_loss(init_weight);


diary off;