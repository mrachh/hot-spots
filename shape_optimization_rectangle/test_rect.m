addpath('../src');
clear;

height = 1.0;
[loss, zk, ud_inf] = rect_loss(height);

% agrees with analytical value

