clear;clc;addpath('../src');


% Computes the gradient of objective when all sides are equal

num_verts = 5

even = ~mod(num_verts, 2)
num_rs = (num_verts - (~even))/2

% Normalize side length so that the area is roughly 1
init_weight = ones(1, num_rs)/sqrt(pi/2);


