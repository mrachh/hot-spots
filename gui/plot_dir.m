function [nothing] = plot_new(chnk_plot_axis, chnkr, sol, zk)
    disp(sol(2))
    %%%
    % 5 text inputs
    % zk, xlim, ylim
    % zk slider; .1 - 40
    % two more imput: F, boundary data

    % when chunkie update (include slide): 
    %     do create F in backgorund
    %     do compute boundary

    % after xlim, ylim,
    %     find exterior points
    %%%

    addpath('../src');
    % chnk_plot_handle = [];
    % kvec = zk .* [cos(direction); sin(direction)];
    nplot = 200;

    % %%%%%%%%%%%%%%%%%%
    % % solve and visualize the solution

    % % build CFIE

    fkern = @(s,t) chnk.helm2d.kern(zk,s,t,'c',1);
    % opdims(1) = 1; opdims(2) = 1;
    % opts = [];
    % start = tic; sysmat = chunkermat(chnkr,fkern,opts);
    % t1 = toc(start);

    % fprintf('%5.2e s : time to assemble matrix\n',t1)

    % sys = 0.5*eye(chnkr.k*chnkr.nch) + sysmat;

    % rhs = -planewave(kvec(:),chnkr.r(:,:)); rhs = rhs(:);
    % start = tic; sol = sys\rhs; t1 = toc(start);

    % fprintf('%5.2e s : time for dense gmres\n',t1)

    % %%%%%%%%%%%%%%%%%%%%%%
    % % End of solve

    rmin = min(chnkr); rmax = max(chnkr);
    xl = rmax(1)-rmin(1);
    yl = rmax(2)-rmin(2);
    xlo = rmin(1)-xl;
    xhi = rmax(1)+xl;
    ylo = rmin(2)-yl;
    yhi = rmax(2)+yl;
    xtarg = linspace(xlo,xhi,nplot); 
    ytarg = linspace(ylo,yhi,nplot);
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

    h=pcolor(chnk_plot_axis ,xxtarg,yytarg,imag(zztarg));
    set(h,'EdgeColor','none');
    colormap(chnk_plot_axis, redblue);
    caxis([-maxu,maxu]);
    % quick fix
    set(gcf,'Visible', 'off');
    % set axis 
    axis(chnk_plot_axis, [xlo xhi ylo yhi]);
end