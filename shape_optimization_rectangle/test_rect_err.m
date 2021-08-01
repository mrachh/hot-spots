clear;clc;addpath('../src');


height_step = 0.2;
num_heights = ceil(1/height_step);
errs = nan(num_heights + 1,1);
heights = nan(num_heights + 1,1);


fprintf(' Error of rect height from 1 to 2')

i = 1;

for height = 1.0:height_step:2
    rect_true = rect_true_loss(height);
    rect_computed = rect_loss(height);
    errs(i) = abs(rect_computed- rect_true);
    heights(i) = height;
    i = i + 1;
end



figure(1);
plot(heights, log10(errs));
xlabel('heights');
ylabel('log 10 err');
title('Error of rectd for height from 1 to 2');