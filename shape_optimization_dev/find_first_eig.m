function [zk, err_nullvec, sigma] = find_first_eig(chnkr, chebabs)
    % INPUT: chnkr, eigenvalue interval [a b]
    % OUTPUT: zk, error in null vector, density sigma

    % Set eps
    eps = 1e-9;
    eps_imag = 1e-4;
    p = chebfunpref; p.chebfuneps = eps;
    p.splitting = 0; p.maxLength=257;

    opts = [];
    opts.flam = true;
    opts.eps = eps;

    detfun = @(zk) helm_dir_det(zk,chnkr,opts);
    detchebs = chebfun(detfun,chebabs,p);
    
    rts = roots(detchebs,'complex');
    rts_real = rts(abs(imag(rts))<eps_imag);

    zk = real(rts_real(1));
    [d,F] = helm_dir_det(zk,chnkr,opts);
    nsys = chnkr.nch*chnkr.k;
    sigma = rskelf_nullvec(F,nsys,1,4);
    xnrm = norm(sigma,'fro');
    xnrm_mv = norm(rskelf_mv(F,sigma),'fro');
    err_nullvec = xnrm_mv/xnrm;
end