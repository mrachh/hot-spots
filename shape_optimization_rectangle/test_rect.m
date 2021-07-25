addpath('../src');
clear;



%Create rect chnkr and plot
[chnkr, zero_loc] = rect_chnk(2.0, true);

figure(2);
zero_quad_pts_pos = chnkr.r(:, :, zero_loc);
zero_quad_pts = chnkr.r(1, :, zero_loc)';
scatter(zero_quad_pts_pos(1, :), zero_quad_pts_pos(2, :));
title('Distribution of chunk containing zero');

chebab = [zero_quad_pts(1) zero_quad_pts(15)];
fun = chebfun(zero_quad_pts, chebab, chebfunpref);
figure(3);
plot(fun);
title('Fitting with chebfun gives a trivial linear function');


%
[dp,varargout] = helm_dprime(zk,chnkr,sigma)




