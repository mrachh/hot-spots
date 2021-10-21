clear;clc;addpath('../src');

a = load('gd_log.mat');
weight = a.weight(7,:);
angles = 0:pi/24:pi;

xs = cos(angles).*weight;
ys = sin(angles).*weight;

weight/weight(1)
% figure(1);
% plot(xs, ys)