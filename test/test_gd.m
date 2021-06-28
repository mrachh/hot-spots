addpath('../src');
clear;

init = 2
optim.gd_grad(@rectangle_fun, init, 0)