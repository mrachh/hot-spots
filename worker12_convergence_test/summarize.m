clear;clc;addpath('../src');

res1 = load('grad_arr1.mat');
res2 = load('grad_arr2.mat');
res3 = load('grad_arr3.mat');
res4 = load('grad_arr4.mat');

grad1 = res1.grad_arr;
grad2 = res2.grad_arr;
grad3 = res3.grad_arr;
grad4 = res4.grad_arr;

log10h1 = -1:-0.01:-2;
log10h2 = -2:-0.01:-3;
log10h3 = -3:-0.01:-4;
log10h4 = -4:-0.01:-5;

grad2 = grad2(2:end,:);
grad3 = grad3(2:end,:);
grad4 = grad4(2:end,:);

log10h2 = log10h2(1,2:end);
log10h3 = log10h3(1,2:end);
log10h4 = log10h4(1,2:end);

grad = cat(1,grad1,grad2,grad3,grad4);
log10h = cat(2,log10h1,log10h2,log10h3,log10h4);

figure(1);
clf;
plot(log10h, grad(:,1),'DisplayName','d/dx1');
title('d/dx1')
xlabel('log10(h)')
ylabel('derivative')
legend;

figure(2);
clf;
plot(log10h, grad(:,2),'DisplayName','d/dx2');
title('d/dx2')
xlabel('log10(h)')
ylabel('derivative')
legend;

figure(3);
clf;
plot(log10h, grad(:,3),'DisplayName','d/dx3');
title('d/dx3')
xlabel('log10(h)')
ylabel('derivative')
legend;

%%%% Convergence test
true_val = grad(201,:);
err = log10(abs(grad - true_val));

figure(4);
plot(log10h, err(:,1));
title('Convergence test on d/dx_1 using value at 1e-3');
ylabel('log10(abs(error))');
xlabel('log10(h)');
axis equal;


figure(5);
plot(log10h, err(:,2));
title('Convergence test on d/dx_2 using value at 1e-3');
ylabel('log10(abs(error))');
xlabel('log10(h)');
axis equal;


figure(6);
plot(log10h, err(:,3));
title('Convergence test on d/dx_3 using value at 1e-3');
ylabel('log10(abs(error))');
xlabel('log10(h)');
axis equal;


true_val = grad(301,:);
err = log10(abs(grad - true_val));

figure(7);
plot(log10h, err(:,1));
title('Convergence test on d/dx_1 using value at 1e-4');
ylabel('log10(abs(error))');
xlabel('log10(h)');
axis equal;


figure(8);
plot(log10h, err(:,2));
title('Convergence test on d/dx_2 using value at 1e-4');
ylabel('log10(abs(error))');
xlabel('log10(h)');
axis equal;


figure(9);
plot(log10h, err(:,3));
title('Convergence test on d/dx_3 using value at 1e-4');
ylabel('log10(abs(error))');
xlabel('log10(h)');
axis equal;
