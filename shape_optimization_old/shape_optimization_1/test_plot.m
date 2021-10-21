clear;clc;addpath('../src');

a = load('gd_log.mat');

normalize = sqrt(pi/2);
th = 0:pi/500:2*pi;
x = cos(th)/normalize;
y = sin(th)/normalize;

for iter = 1:7
    figure(iter);
    clf;
    plot(x,y,'r');
    xlim([-1 1]);
    ylim([-1 1]);
    axis equal;
    chnkr = polysymeven_chnk(a.weight(iter,:));
    hold on;
    plot(chnkr, 'b');
    legend('Circle','50-gon');
    title(sprintf('Iteration: %d', iter));
end

