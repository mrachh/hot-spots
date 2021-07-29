addpath('../src');
clear;
clc;

% height = 1.0;
% [loss, zk, ud_inf] = rect_loss(height,2);

% agrees with analytical value sqrt(2) at height = 1.0

height_step = .5;
num_heights = floor(1/height_step);
losss = zeros(num_heights);
zks = zeros(num_heights);
ud_infs = zeros(num_heights);

fid = 1;
for height = 1:height_step:2
    start = tic;
    [loss, zk, ud_inf] = rect_loss(height, fid);
    losss(fid) = loss;
    zks(fid) = zk;
    ud_infs(fid) = ud_inf;
    fid = fid + 1;
    fprintf('Progress: %d/%d; Time: %5.2e \n', fid, num_heights, toc(start));
end


