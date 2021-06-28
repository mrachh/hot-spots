addpath('../src');
clear;

init = 2
[res, log] = optim.gradient_descent(@rectangle_fun, init, 0)