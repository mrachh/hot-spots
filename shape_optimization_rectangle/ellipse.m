clear; clc;
addpath('../src');

function [zk, err_nullvec, sigma] = find_eig(chnkr)

    chebabs = [2,5];
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

function u_2 = find_u_2(chnkr, zk, sigma, center)
    
    k = 16;
    [xang,yang,wtot] = get_chunkie_quads(chnkr,center,k);
    targets = [xang yang]';
    fkern = @(s,t) chnk.helm2d.kern(zk,s,t,'d',1);
    fprintf('Running chunkerkerneval on %d targets...\n', length(wtot));
    start = tic; u = chunkerkerneval(chnkr,fkern,sigma,targets);
    fprintf('Time for chunkerkerneval: %5.2e\n', toc(start));
    u_2 = sqrt(sum((abs(u).^2).*wtot));


end


function ud_inf = find_ud_inf(chnkr, zk, sigma, figure_id)

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

    ichind = ceil(iind/chnkr.k);
    [~,~,u,v] = lege.exps(chnkr.k);
    y = reshape(y,[chnkr.k,chnkr.nch]);
    ycoefs = u*y(:,ichind);
    ydcoefs = lege.derpol(ycoefs);

    ccheb = leg2cheb(ycoefs);
    p = chebfun(ccheb,'coeffs');

    cchebd = leg2cheb(ydcoefs);
    pd = chebfun(cchebd,'coeffs');
    rr = [roots(pd) -1 1];
    yy = p(rr);
    [ymax_final,iind] = max(yy);
    ymax_loc = rr(iind);
    ud_inf = ymax_final;

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