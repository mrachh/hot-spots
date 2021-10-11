clear;clc;addpath('../src');

diary('test_optimization_diary.txt');

num_verts = 4;
num_params = num_verts;

rs = [1 .5 1 .5 1 .5 1 .5 1 .5];


idx = ones(size(rs))
[isconvex, idx_conv] = check_convex(rs)

[isconvex, idx_conv] = check_convex(rs, idx_conv)
