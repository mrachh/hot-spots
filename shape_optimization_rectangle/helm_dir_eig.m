function [zk, err_nullvec, sigma] = helm_dir_eig(chnkr)

    chebabs = [1.5,4];
    eps = 1e-5;
    p = chebfunpref; p.chebfuneps = eps;
    p.splitting = 0; p.maxLength=257;

    opts = [];
    opts.flam = true;
    opts.eps = eps;

    detfun = @(zk) helm_dir_det(zk,chnkr,opts);

    detchebs = chebfun(detfun,chebabs,p);

    rts = roots(detchebs,'complex');
    rts_real = rts(abs(imag(rts))<eps*10);

    zk = real(rts_real(1));
    [d,F] = helm_dir_det(zk,chnkr,opts);
    nsys = chnkr.nch*chnkr.k;
    sigma = rskelf_nullvec(F,nsys,1,4);
    xnrm = norm(sigma,'fro');
    xnrm_mv = norm(rskelf_mv(F,sigma),'fro');
    err_nullvec = xnrm_mv/xnrm;
    fprintf('Error in null vector: %5.2e\n',err_nullvec);

end