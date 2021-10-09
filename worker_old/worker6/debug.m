clear;clc;addpath('../src');

% weight after first iteration
w = [0.7190    0.7357    0.7562    0.7811    0.8110    0.7899    0.7729 0.7421    0.7163    0.6949    0.6774    0.6633    0.6523    0.6441 0.6387    0.6358    0.6354    0.6376    0.6423    0.6496    0.6598 0.6583    0.6595    0.6366    0.6177    0.6021    0.5896    0.5798 0.5726    0.5677    0.5652    0.5631    0.5632    0.5634    0.5634 0.5656    0.5645    0.5638    0.5655    0.5636    0.5639    0.5638 0.5643    0.5643    0.5630    0.5640    0.5638    0.5646    0.5651 0.5651    0.5634    0.5640    0.5623    0.5628    0.5639    0.5662 0.5707    0.5775    0.5869    0.5990    0.6141    0.6325    0.6547 0.6813    0.7131    0.7511    0.7502    0.7522    0.7140    0.6821 0.6553    0.6330    0.6145    0.5994    0.5873    0.5778    0.5709 0.5664    0.5641    0.5641    0.5657    0.5646    0.5646    0.5660 0.5645    0.5652    0.5654    0.5655    0.5678    0.5724    0.5794 0.5890    0.6012    0.6165    0.6351    0.6575    0.6845    0.6887 0.6958    0.7058]

chnkr = chnk_poly(w);

eps = 1e-9;

chebabs = [1 10];
p = chebfunpref; p.chebfuneps = eps;
p.splitting = 0; p.maxLength=257;

opts = [];
opts.flam = true;
opts.eps = eps;

detfun = @(zk) helm_dir_det(zk,chnkr,opts);
detchebs = chebfun(detfun,chebabs,p);


error('nothing')
rts = roots(detchebs,'complex');
rts_real = rts(abs(imag(rts))<eps*10);

zk = real(rts_real(1));
[d,F] = helm_dir_det(zk,chnkr,opts);
nsys = chnkr.nch*chnkr.k;
sigma = rskelf_nullvec(F,nsys,1,4);
xnrm = norm(sigma,'fro');
xnrm_mv = norm(rskelf_mv(F,sigma),'fro');
err_nullvec = xnrm_mv/xnrm;