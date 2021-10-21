clear;clc;addpath('../src');

% Rectangle
alpha = sqrt(3);
step = 1e-2;
a = alpha;
b = 1;

xs = 0:step:alpha;
ys = 1:-step:0;
[X, Y] = meshgrid(xs, ys);
u = sin((pi/a).*X).*sin((pi/b).*Y);

ux = (pi/a) .* cos((pi/a).*X) .* sin((pi/b).*Y);
uy = (pi/b) .* sin((pi/a).*X) .* cos((pi/b).*Y);
ux_abs = abs(ux);
uy_abs = abs(uy);
gradu_2 = (ux_abs.^2 + uy_abs.^2) .^(1/2);

figure(1);
heatmap(xs, ys, u);
colorbar
title('first eigenfunction of rectangle of aspect ratio sqrt 3')

figure(2);
heatmap(xs, ys, gradu_2);
colorbar
title('grad u euclidean norm')



figure(3);
heatmap(xs, ys, ux_abs);
colorbar
title('du/dx')

figure(4);
heatmap(xs, ys, uy_abs);
colorbar
title('du/dy')


