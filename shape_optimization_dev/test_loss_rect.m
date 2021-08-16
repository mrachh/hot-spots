clear;clc;addpath('../src');

loss_params = struct(...
    'default_chebabs',      [2 6], ...
    'chnk_fun',             @chnk_rectangle, ...
    'gradu_p',              '3', ...
    'u_q',                  '4' ...
);

weight = [1];
loss_true = rect_true_loss(weight, loss_params)

error('nothing')
loss_computed = loss(weight, loss_params);
diff = loss_computed - loss_true;

fprintf('Error is %.16f\n', diff);