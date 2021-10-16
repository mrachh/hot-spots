clear;clc;addpath('../src');

% max step = 69

iter_to_plot = [1 2 3 4 5];
res = load('worker10.mat');
num_verts = 20;

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

figure(2);
clf;

i = 5
rads = res.weight(iter, :);
grad = res.grad(iter,:);
plot(chnk_poly(rads));
hold on

for j = 1:num_verts
    theta = 2*pi*(j-1)/num_verts;
    x = rads(j) * cos(theta);
    y = rads(j) * sin(theta);
    if grad(j)>=0
        h = plot(x,y,'o','MarkerFaceColor','r','MarkerSize',20);
    else
        h = plot(x,y,'o','MarkerFaceColor','b','MarkerSize',20);
    end
    hold on
end
title('20 point gradient in last iteration; red outward blue inward')
axis equal


figure(3);
clf;

colormap parula;


i = 5
rads = res.weight(iter, :);
grad = res.grad(iter,:);
max_grad = max(abs(grad));
abs_grad = abs(grad);
caxis([-max_grad max_grad]);
plot(chnk_poly(rads));
hold on

cmap = jet;
grad_color = ceil(((grad+max_grad)./(2*max_grad)).*255.0);

for j = 1:num_verts
    theta = 2*pi*(j-1)/num_verts;
    x = rads(j) * cos(theta);
    y = rads(j) * sin(theta);
    h = plot(x,y,'o','MarkerFaceColor',cmap(grad_color(j),:),'MarkerSize',20);
    hold on
end
colormap jet;
caxis([-max_grad max_grad]);
colorbar
title('20 point gradient value')
axis equal