function [e_val, err_nullvec, sigma] = helm_dir_eig(chnkr)

    EPS = 1e-7;

    % Set chebfun param
    p = chebfunpref; p.chebfuneps = EPS;
    p.splitting = 0; p.maxLength=257;

    % Interval for eigenvalue search
    chebabs = [2,5];

    % Call chebfun
    assert(checkadjinfo(chnkr) == 0);
    opts = []; opts.flam = true; opts.eps = eps;
    detfun = @(zk) helm_dir_det(zk,chnkr,opts);
    detchebs = chebfun(detfun,chebabs,p);

    figure(1);
    plot(abs(detchebs));

    % Find all roots
    rts = roots(detchebs,'complex');
    rts_real = rts(abs(imag(rts))<EPS*10);

    % Get first real root
    zk = real(rts_real(1));
    [d,F] = helm_dir_det(zk,chnkr,opts);
    nsys = chnkr.nch*chnkr.k;
    e_val = zk^2;

    % compute sigma
    sigma = rskelf_nullvec(F,nsys,1,4);
    xnrm = norm(sigma,'fro');
    xnrm_mv = norm(rskelf_mv(F,sigma),'fro');
    err_nullvec = xnrm_mv/xnrm;


end