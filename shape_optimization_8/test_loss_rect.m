clear;addpath('../src');

loss_params = struct(...
    'default_chebabs',      [2 6], ...
    'chnk_fun',             @chnk_rectangle, ...
    'gradu_p',              '150', ...
    'u_q',                  '2' ...
);

weight = [1];
loss_true = rect_true_loss(weight, loss_params)


loss_computed = loss(weight, loss_params);
diff = loss_computed - loss_true;

fprintf('Error is %.16f\n', diff);