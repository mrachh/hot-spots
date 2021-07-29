function [zk, err_nullvec, sigma] = compute_eig(chnkr, chebabs)

    % Computes the first laplacian (dirichlet boundary) eigenvalue
    % INPUT:    "chnkr"         chunkie object
    %           "chebabs"       [a b] where eigenvalue lives in
    %
    % OUTPUT:   "zk"            wave number (or equivalently sqrt(eigenval))
    %           "sigma"         sigma
    %           "err_nullvec"   error of sigma


    eps = 1e-7;
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