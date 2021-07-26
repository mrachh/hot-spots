addpath('../src');
clear;




%Create rect chnkr and plot
[chnkr, zero_loc] = rect_chnk(2.0, false);


zero_quad_pts_pos = chnkr.r(:, :, zero_loc);
zero_quad_pts = chnkr.r(1, :, zero_loc)';
% figure(2);
% scatter(zero_quad_pts_pos(1, :), zero_quad_pts_pos(2, :));
% title('Distribution of chunk containing zero');

chebab = [zero_quad_pts(1) zero_quad_pts(15)];
fun = chebfun(zero_quad_pts, chebab, chebfunpref);
% figure(3);
% plot(fun);
% title('Fitting with chebfun gives a trivial linear function');


[e_val, err_nullvec, sigma] = helm_dir_eig(chnkr)

% %
% [dp,varargout] = helm_dprime(zk,chnkr,sigma)




