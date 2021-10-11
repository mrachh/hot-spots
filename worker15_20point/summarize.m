clear;clc;addpath('../src');

res = load('gd.mat');

% figure(1)
% plot(log10(res.loss + 0.365584022807387))
% title('log10 distance from optimal objective')

% figure(2)
% plot(log10(res.gradnorm))
% title('log10 grad norm')

figure(3)
clf;
iter = 16
rads = res.weight(iter, :);
[~, idx] = check_convex(rads);
plot(chnk_poly(rads, idx));
hold on
num_verts = length(rads);
for j = 1:num_verts
    if idx(j)
        theta = 2*pi*(j-1)/num_verts;
        x = rads(j) * cos(theta);
        y = rads(j) * sin(theta);
        h = plot(x,y,'r*');
        h.Annotation.LegendInformation.IconDisplayStyle = 'off';
        hold on
    end
end