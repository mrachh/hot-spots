function [ud_inf, max_grad_loc] = max_grad(chnkr, zk, sigma, figure_id)

    % Computes gradient at origin

    xplt_range = [-.6 .6];
    yplt_range = [-.1, 2.1];

    dudncomputed = helm_dprime(zk,chnkr,sigma);
    r = chnkr.r(:);
    r = reshape(r,[2,chnkr.k*chnkr.nch]);
    wts = weights(chnkr);
    wts = reshape(wts,[chnkr.k*chnkr.nch,1]);

    rint = sum(dudncomputed.*wts);
    rint = rint/abs(rint);
    y = real(dudncomputed./rint);


    [ymax,iind] = max(y);


    [rn,dn,d2n,dist,tn,ichind] = ...
        nearest(chnkr, [0 0], 1:chnkr.nch);
    % ichind = ceil(iind/chnkr.k);
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
    ud_inf = ymax_final;

    left = chnkr.r(1,1,ichind);
    right = chnkr.r(1,end,ichind);
    a = (right - left)/2;
    b = right - a;
    max_grad_loc = a * ymax_loc + b;


    if nargin > 3
        if figure_id > 0
            figure;
            clf;
            plot(chnkr,'-b');
            hold on;
            xs = reshape(chnkr.r(1,:), chnkr.k * chnkr.nch,1);
            ys = reshape(chnkr.r(2,:), chnkr.k * chnkr.nch,1);
            zs = reshape(y, chnkr.k * chnkr.nch, 1);
            [zmax, zmax_ind] = max(zs);
            scatter(xs, ys, 10, zs, 'filled');
            plot(xs(zmax_ind), ys(zmax_ind), '.r','MarkerSize',20);
            xlim(xplt_range);
            ylim(yplt_range);
            saveas(gcf, strcat('temp/',mat2str(figure_id),'.png'));
            close;
        end
    end

end