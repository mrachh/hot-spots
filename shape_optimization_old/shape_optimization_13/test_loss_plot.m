clear;addpath('../src');

figure(1);
clf;

for udnorm_ord = 5:10

    loss_params = struct(...
        'default_chebabs',      [2 6], ...
        'chnk_fun',             @chnk_rectangle, ...
        'udnorm_ord',           mat2str(udnorm_ord), ...
        'unorm_ord',                  '5' ...
    );

    ys = nan(1,10000);
    alphas = nan(1,10000);
    i = 1;
    for alpha = 0.001:0.001:5
        ys(i) = -rect_true_loss(alpha, loss_params);
        alphas(i) = alpha;
        i = i+1;
    end


    a = plot(alphas,ys,'DisplayName',mat2str(udnorm_ord));
    hold on


end

legend