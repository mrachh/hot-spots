clear;clc;addpath('../src');

res = load('worker2.mat');

% 20 points convergence test
% assume that 1e-4 is true val
% which has index 26


true_grad = res.grad_arr(26, :);
err_grad = res.grad_arr - true_grad;
abs_log_err_grad = log10(abs(err_grad));
hs = log10(res.h_arr(1:36));

figure(1);
clf;

for i = 1:20
    plot(hs, abs_log_err_grad(:,i), ...
        'DisplayName', mat2str(i));
    hold on;

end