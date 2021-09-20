clear;clc;addpath('../src');

num_verts = 20;
num_params = num_verts;

weight = ones(1, num_params)/sqrt(pi/2);
grad_arr = nan(100, num_params);
h_arr = nan(1, 100);

loss_params = struct(...
    'default_chebabs',      [1 10], ...
    'chnk_fun',             @chnk_poly, ...
    'udnorm_ord',              'inf', ...
    'unorm_ord',                  '2' ...
)


[~, chebab] = loss(weight,loss_params);

% Convergence test

num_grads = 0;
for logh = -1.5:-0.1:-5
    num_grads = num_grads + 1
    hspace = 10^(logh)
    h_arr(num_grads) = hspace;
    grad = zeros(1, num_params);
    for param_idx = 1:num_params
        direction = zeros(1, num_params);
        direction(param_idx) = hspace;
        left = loss(weight - direction, loss_params, chebab);
        right = loss(weight + direction, loss_params, chebab);
        grad(param_idx) = (right - left) / (2 * hspace);
    end
    grad_arr(num_grads,:) = grad;
end

grad_arr = grad_arr(1:num_grads,:);