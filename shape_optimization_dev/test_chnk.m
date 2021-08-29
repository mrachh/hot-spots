clear;clc;addpath('../src');

num_verts = 5;
ws = ones(num_verts)/sqrt(pi/2);
[chnkr, center] = chnk_poly(ws);
plot(chnk_poly(ws));