addpath('../src');
clear;

[chnkr, zero_loc] = rect_chnk(2.0, true);

figure(2);
test = chnkr.r(:, :, zero_loc);
scatter(test(1,:), test(2,:));
title('Interval containing origin')