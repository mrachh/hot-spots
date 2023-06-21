clear;clc;addpath('../src');

% max step = 69

iter_to_plot = [10 20 30 40 50];
res = load('worker5.mat');
num_verts = 10;

num_iters = length(iter_to_plot);


figure(1);
clf;

for i = 1:num_iters
    iter = iter_to_plot(i);
    rads = res.weight(iter, :);
    plot(chnk_poly(rads), 'DisplayName', mat2str(iter));
    hold on

    for j = 1:num_verts
        theta = 2*pi*(j-1)/num_verts;
        x = rads(j) * cos(theta);
        y = rads(j) * sin(theta);
        h = plot(x,y,'r*');
        h.Annotation.LegendInformation.IconDisplayStyle = 'off';
        hold on
    end

end


axis equal;
legend;