clear;clc;

% First root of J_1
zk = 3.831705970207512;
step = 1e-3;
xs = -1:step:1;
ys = -1:step:1;
[X,Y] = meshgrid(xs, ys);
R = (X.^2 + Y.^2).^(1/2);
disk = ones(size(X));
disk(R>1) = nan;
cos_theta = X./R;
sin_theta = Y./R;

U = (besselj(1, zk .* R).*sin_theta).*disk;

figure(1);
clf;
h = pcolor(flipud(U));
set(h,'EdgeColor','none');

colorbar