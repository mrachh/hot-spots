function result = ud_origin(chnkr, zk, sigma)

    % Computes gradient at the origin
    dudncomputed = helm_dprime(zk,chnkr,sigma);
    r = chnkr.r(:);
    r = reshape(r,[2,chnkr.k*chnkr.nch]);
    wts = weights(chnkr);
    wts = reshape(wts,[chnkr.k*chnkr.nch,1]);
    rint = sum(dudncomputed.*wts);
    rint = rint/abs(rint);
    y = real(dudncomputed./rint);
    % find iind for origin
    points = reshape(chnkr.r,[2, chnkr.k*chnkr.nch]);
    points_xs = points(1,:);
    points_ys = points(2,:);
    [left_xmin,left_xindex] = min(abs(points_xs)+(points_xs>0)+abs(points_ys));
    [right_xmin,right_xindex] = min(abs(points_xs)+(points_xs<0)+abs(points_ys));
    left_chnk_index = ceil(left_xindex/chnkr.k);
    right_chnk_index = ceil(right_xindex/chnkr.k);

    % treat sym/asym differently
    if left_chnk_index == right_chnk_index
        % within one chunk
        [~,~,u,v] = lege.exps(chnkr.k);
        y = reshape(y,[chnkr.k,chnkr.nch]); % this seems to flip the ordering
        x = reshape(points_xs,[chnkr.k,chnkr.nch]);
        x = x(:,left_chnk_index);
        ycoefs = u*y(:,left_chnk_index);
        chebfun_param = chebfunpref; chebfun_param.chebfuneps = eps;
        chebfun_param.splitting = 0; chebfun_param.maxLength=512;
        ccheb = leg2cheb(ycoefs);
        p = chebfun(ccheb,'coeffs', chebfun_param);
        quad_pts = legpts(chnkr.k);
        cheb_start = quad_pts(1);
        cheb_end = quad_pts(chnkr.k);
        chnk_start = x(1);
        chnk_end = x(chnkr.k);
        slope = (cheb_start-cheb_end)/(chnk_start-chnk_end);
        cheb_zero = slope*(-chnk_start)+cheb_start;
        result = p(cheb_zero);
    else
        % between two chunks
        left_y = y(left_xindex);
        right_y = y(right_xindex);
        result = (left_y+right_y)/2;
    end

end