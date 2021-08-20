clear;addpath('../src');

loss_params = struct(...
    'default_chebabs',      [2 6], ...
    'chnk_fun',             @chnk_rectangle, ...
    'udnorm_ord',              '2', ...
    'unorm_ord',                  '2' ...
);

weight = [0.7];
alpha = 1/weight;
loss_true = rect_true_loss(alpha, loss_params);


loss_computed = loss(weight, loss_params);
diff = loss_computed - loss_true;

fprintf('Error is %.16f\n', diff);