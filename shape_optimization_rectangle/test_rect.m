addpath('../src');
clear;




%Create rect chnkr and plot
[chnkr, zero_loc] = rect_chnk(1.0, true);


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




% [e_val, err_nullvec, sigma] = helm_dir_eig(chnkr)

% %
% [dp,varargout] = helm_dprime(zk,chnkr,sigma)



chebabs = [0.1,5];
eps = 1e-7;
p = chebfunpref; p.chebfuneps = eps;
p.splitting = 0; p.maxLength=257;

opts = [];
opts.flam = true;
opts.eps = eps;

detfun = @(zk) helm_dir_det(zk,chnkr,opts);

detchebs = chebfun(detfun,chebabs,p);
figure(2)
plot(abs(detchebs))

rts = roots(detchebs,'complex');
rts_real = rts(abs(imag(rts))<eps*10);

zk = real(rts_real(1));
[d,F] = helm_dir_det(zk,chnkr,opts);
nsys = chnkr.nch*chnkr.k;
xnull = rskelf_nullvec(F,nsys,1,4);
xnrm = norm(xnull,'fro');
xnrm_mv = norm(rskelf_mv(F,xnull),'fro');
err_nullvec = xnrm_mv/xnrm;
fprintf('Error in null vector: %5.2e\n',err_nullvec);



