addpath('../src');
clear;

GRAD_HSPACE = 1e-14


init = 2
grad = optim.gd_grad(@rectangle_fun, init, GRAD_HSPACE)