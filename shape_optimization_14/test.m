clear;clc;addpath('../src');

num_verts = 20;
num_params = num_verts / 2;
poly_param = ones(1, num_params) / sqrt(pi/2);
h_step = 1e-3;

udnorm_grad = nan(1, num_params);
loss_grad = nan(1, num_params);
eigenval_grad = nan(1, num_params);
unorm_grad = nan(1, num_params);


loss_params = struct(...
    'default_chebabs',      [2 6], ...
    'chnk_fun',             @chnk_polyeven, ...
    'udnorm_ord',              'inf', ...
    'unorm_ord',                  '2' ...
);

chebabs = [2 6];

for i = 1:num_params
    i
    direction = zeros(1, num_params);
    direction(i) = h_step;
    [loss_right, chebabs, zk_right, udnorm_right, unorm_right] = ...
        loss(poly_param + direction, loss_params, chebabs);
    [loss_left, chebabs, zk_left, udnorm_left, unorm_left] = ...
        loss(poly_param - direction, loss_params, chebabs);
    eigenval_left = zk_left^2;
    eigenval_right = zk_right^2;
    loss_grad(i) = (loss_right - loss_left)/(2*h_step);
    udnorm_grad(i) = (udnorm_right - udnorm_left)/(2*h_step);
    unorm_grad(i) = (unorm_right - unorm_left)/(2*h_step);
    eigenval_grad(i) = (eigenval_right - eigenval_left)/(2*h_step);
end