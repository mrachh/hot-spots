addpath('../src');
clear;
clc;

% height = 1.0;
% [loss, zk, ud_inf] = rect_loss(height,2);

% agrees with analytical value sqrt(2) at height = 1.0


num_heights = 10;

[x,~,~,~] = lege.exps(num_heights);
x = 3 * (x+1)/2 + 1;
losss = zeros(num_heights, 1);
zks = zeros(num_heights, 1);
ud_infs = zeros(num_heights, 1);

fid = 1;
for i = 1:num_heights
    height = x(i);
    start = tic;
    [loss, zk, ud_inf] = ellipse_loss(height, fid);
    losss(fid) = loss;
    zks(fid) = zk;
    ud_infs(fid) = ud_inf;
    fid = fid + 1;
    fprintf('Progress: %d/%d; Time: %5.2e \n', fid, num_heights, toc(start));
end


