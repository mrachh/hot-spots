clear;clc;addpath('../src');

res = load('gd_log2.mat');
num_steps = 100;

for i = 1:num_steps
    chnkr = polysymeven_chnk(res.weight(i,:));
    f = figure(1);
    clf;
    plot(chnkr);
    xlim([-2 2]);
    ylim([-1 3]);
    title(sprintf('iter: %d, loss: %.6f',i,res.loss(i)));
    f.Position = [100 100 600 600];
    saveas(f,sprintf('temp/2/%d.png',i));
end