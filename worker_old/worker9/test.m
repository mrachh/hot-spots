clear;clc;addpath('../src');

diary

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
for logh = -2:-0.05:-4
    num_grads = num_grads + 1
    hspace = 10^(logh)
    h_arr(num_grads) = hspace;

    gradh = zeros(1, num_params);
    for param_idx = 1:num_params
        direction = zeros(1, num_params);
        direction(param_idx) = hspace;
        left = loss(weight - direction, loss_params, chebab);
        right = loss(weight + direction, loss_params, chebab);
        gradh(param_idx) = (right - left) / (2 * hspace);
    end

    hspace = 2 * hspace;
    grad2h = zeros(1, num_params);
    for param_idx = 1:num_params
        direction = zeros(1, num_params);
        direction(param_idx) = hspace;
        left = loss(weight - direction, loss_params, chebab);
        right = loss(weight + direction, loss_params, chebab);
        grad2h(param_idx) = (right - left) / (2 * hspace);
    end

    grad = (4.*gradh - grad2h)./3;

    grad_arr(num_grads,:) = grad;
    save('grad_arr','grad_arr');
    save('h_arr','h_arr');
end

grad_arr = grad_arr(1:num_grads,:);

save('grad_arr','grad_arr');