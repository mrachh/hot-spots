function [utot] = plot_new(chnk_plot_axis, chnkr, k, direction, xlimit, ylimit)

    addpath('../src');
    chnk_plot_handle = [];

    % TODO: kvec by angle direction
    kvec = k .* [cos(direction); sin(direction)];
    zk = k

    %%%%%%%%%%%%%%%%%%
    % solve and visualize the solution

    % build CFIE

    fkern = @(s,t) chnk.helm2d.kern(zk,s,t,'c',1);
    opdims(1) = 1; opdims(2) = 1;
    opts = [];
    start = tic; sysmat = chunkermat(chnkr,fkern,opts);
    t1 = toc(start);

    fprintf('%5.2e s : time to assemble matrix\n',t1)

    sys = 0.5*eye(chnkr.k*chnkr.nch) + sysmat;

    rhs = -planewave(kvec(:),chnkr.r(:,:)); rhs = rhs(:);
    start = tic; sol = gmres(sys,rhs,[],1e-13,100); t1 = toc(start);

    fprintf('%5.2e s : time for dense gmres\n',t1)

    nplot = 400;
    xtarg = linspace(xlimit(1),xlimit(2),nplot); 
    ytarg = linspace(ylimit(1),ylimit(2),nplot);
    [xxtarg,yytarg] = meshgrid(xtarg,ytarg);
    targets = zeros(2,length(xxtarg(:)));
    targets(1,:) = xxtarg(:); targets(2,:) = yytarg(:);

    %

    start = tic; in = chunkerinterior(chnkr,targets); t1 = toc(start);
    out = ~in;

    fprintf('%5.2e s : time to find points in domain\n',t1)

    % % compute layer potential based on oversample boundary

    start = tic;
    uscat = chunkerkerneval(chnkr,fkern,sol,targets(:,out)); t1 = toc(start);
    fprintf('%5.2e s : time for kernel eval (for plotting)\n',t1)

    uin = planewave(kvec,targets(:,out));
    utot = uscat(:)+uin(:);

    %

    maxin = max(abs(uin(:)));
    maxsc = max(abs(uin(:)));
    maxtot = max(abs(uin(:)));

    maxu = max(max(maxin,maxsc),maxtot);

    zztarg = nan(size(xxtarg));
    zztarg(out) = utot;

    axes(chnk_plot_axis)
    
    h=pcolor(xxtarg,yytarg,imag(zztarg));
    set(h,'EdgeColor','none')
    % hold on
    % plot(chnkr,'LineWidth',2)
    colormap(redblue)
    caxis([-maxu,maxu])

end