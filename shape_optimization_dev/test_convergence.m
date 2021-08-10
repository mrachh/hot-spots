clear;clc;addpath('../src');

num_verts = 4;
num_params = num_verts /2;

weight = ones(1, num_params)/sqrt(pi/2);
grad_arr = nan(100, num_params);
[~, chebab] = polysymeven_loss(weight);

num_grads = 0;
for logh = -10:2:-2
    num_grads = num_grads + 1
    hspace = 10^(logh);
    grad = zeros(1, num_params);
    for param_idx = 1:num_params
        direction = zeros(1, num_params);
        direction(param_idx) = hspace;
        left = polysymeven_loss(weight - direction, chebab);
        right = polysymeven_loss(weight + direction, chebab);
        grad(param_idx) = (right - left) / (2 * hspace);
    end
    grad_arr(num_grads,:) = grad;
end

grad_arr = grad_arr(1:num_grads,:);
dx_arr = grad_arr(:,1);
dy_arr = grad_arr(:,2);
dx_err = dx_arr - dx_arr(1);
dy_err = dy_arr - dy_arr(1);