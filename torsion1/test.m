clear;clc;addpath('../src');


num_params = 10;
rs = ones(1, num_params);
chnkr = chnk_poly(rs);

% kern = (x-x') dot n(x') / (x-x')^2
% system: (-pi*id + kern_mat)sigma = x_2^2/2


