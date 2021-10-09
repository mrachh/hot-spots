function [ud_p] = gradu_norm(chnkr, zk, sigma, p)

    % Computes gradient at the origin

    if isinf(p)

        dudncomputed = helm_dprime(zk,chnkr,sigma);
        r = chnkr.r(:);
        r = reshape(r,[2,chnkr.k*chnkr.nch]);
        wts = weights(chnkr);
        wts = reshape(wts,[chnkr.k*chnkr.nch,1]);
        rint = sum(dudncomputed.*wts);
        rint = rint/abs(rint);
        y = real(dudncomputed./rint);

        [ymax,iind] = max(y);

        ichind = ceil(iind/chnkr.k);
        [~,~,u,v] = lege.exps(chnkr.k);
        y = reshape(y,[chnkr.k,chnkr.nch]);
        ycoefs = u*y(:,ichind);
        ydcoefs = lege.derpol(ycoefs);
        chebfun_param = chebfunpref; chebfun_param.chebfuneps = eps;
        chebfun_param.splitting = 0; chebfun_param.maxLength=257;

        ccheb = leg2cheb(ycoefs);
        p = chebfun(ccheb,'coeffs', chebfun_param);

        cchebd = leg2cheb(ydcoefs);
        pd = chebfun(cchebd,'coeffs', chebfun_param);
        rr = [roots(pd) -1 1];
        yy = p(rr);
        [ymax_final,iind] = max(yy);
        ymax_loc = rr(iind);
        ud_p = ymax_final;
    
    else

        dudncomputed = helm_dprime(zk,chnkr,sigma);
        wts = weights(chnkr);
        wts = reshape(wts,[chnkr.k*chnkr.nch,1]);
        rint = sum(dudncomputed.*wts);
        rint = rint/abs(rint);
        y = real(dudncomputed./rint);
        ud_p = sum((abs(y).^p).*wts)^(1/p);

    end

end