clear;clc;addpath('../src');


height_step = 0.2;
num_heights = ceil(1/height_step);
% Use a small step to approximate true derivative
hspace_true = 1e-12;
num_hspaces = 10;
hspace_step = (6 - 0.5) / (num_hspaces);
hspaces = nan(num_hspaces + 1,1);
errs = nan(num_hspaces + 1,1);


fprintf(' Error of rectdd hspace from 1e-.5 to 1e-6')

i = 1;
for hspace_log10 = 0.5 : hspace_step : 6;
    hspace = 10^(-hspace_log10);
    % Computes average error made over 6 different heights
    total_err = 0;
    for height = 1.32:height_step:2
        left = rect_true_loss(height - hspace_true);
        right = rect_true_loss(height + hspace_true);
        center = rect_true_loss(height);
        rectd_true = (right - 2 * center +  left) / (hspace_true ^ 2);

        left = rect_loss(height - hspace);
        right = rect_loss(height + hspace);
        center = rect_loss(height);
        rectd_computed = (right - 2 * center +  left) / (hspace ^ 2);

        total_err = total_err + abs(rectd_true - rectd_computed);

    end
    fprintf('Progress %d/%d\n', i, num_hspaces);
    errs(i) = total_err / num_heights;
    hspaces(i) = hspace;
    i = i + 1;
end


figure(1);
plot(log10(hspaces), log10(errs));
title('Error of rectd hspace from 10^-0.5 to 10^-6');