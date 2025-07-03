clear;clc;addpath('../src');

% Specify number of vertices
num_verts = 3;
num_params = num_verts;

% Parameters for loss/objective function
% Modify default_chebabs if you have a good guess of zk
loss_params = struct(...
    'default_chebabs',      [1 10], ...
    'chnk_fun',             @chnk_poly, ...
    'udnorm_ord',              'inf', ...
    'unorm_ord',                  '2' ...
)


% Specify radii
radii = ones(1, num_params)/sqrt(pi/2);
[chnkr, center] = loss_params.chnk_fun(radii);

hspace = 1e-3;
direction = zeros(1, num_params);
direction(1) = hspace;


[chnkr2, center2] = loss_params.chnk_fun(radii+direction);

figure(1)
plot(chnkr)


figure(2)
plot(chnkr2)

return

% Specify step size for centered difference



% Initialize zk interval with a single loss evaluation
[~, chebab] = loss(radii,loss_params);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Compute gradient using centered difference

% Initialize gradient vector
grad = zeros(1, num_params);

for param_idx = 1:num_params

    % Compute d/dx_i where i = param_idx
    direction = zeros(1, num_params);
    direction(param_idx) = hspace;

    % Take a step backwawrd
    left = loss(radii - direction, loss_params, chebab);

    % Take a step forward
    right = loss(radii + direction, loss_params, chebab);

    % Evaluate centered difference
    grad(param_idx) = (right - left) / (2 * hspace);

end

grad_cd = grad;

% Compute gradient using centered difference and Richardson

% Compute cd with h
grad = zeros(1, num_params);
for param_idx = 1:num_params
    direction = zeros(1, num_params);
    direction(param_idx) = hspace;
    left = loss(radii - direction, loss_params, chebab);
    right = loss(radii + direction, loss_params, chebab);
    grad(param_idx) = (right - left) / (2 * hspace);
end
gradh = grad;

% Compute cd with 2h
grad = zeros(1, num_params);
hspace = hspace * 2;
for param_idx = 1:num_params
    direction = zeros(1, num_params);
    direction(param_idx) = hspace;
    left = loss(radii - direction, loss_params, chebab);
    right = loss(radii + direction, loss_params, chebab);
    grad(param_idx) = (right - left) / (2 * hspace);
end
grad2h = grad;

% Richardson
grad = (4.*gradh - grad2h)./3;
grad_rich = grad;





