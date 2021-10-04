clear;clc;addpath('../src');

ws = load('workspace.mat');
grads = ws.grad_arr;
hs = ws.h_arr(1:36);


figure(1);
clf;
for i = 1:20
    plot(log10(hs),log10(grads(:,i)),'DisplayName',sprintf('dx%d',i));
    hold on
end
legend
xlabel('log10(h)')
ylabel('log10(d/dxi)')
title('gradient convergence test on a circle')
