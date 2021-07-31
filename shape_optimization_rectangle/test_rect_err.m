clear;clc;addpath('../src');


height_step = 1e-1;
num_heights = ceil(1/height_step);

rect_computed = nan(num_heights);
rect_true = nan(num_heights);

i = 1;
for height = 1:height_step:2
    rect_true(i) = optim.tests.test4(height);
    rect_computed(i) = rect_loss(height);
    fprintf('Progress %d/%d\n', i, num_heights);
    i = i+1;
end

rect_err = rect_computed - rect_true;