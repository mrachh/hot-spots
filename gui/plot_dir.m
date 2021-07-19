function [h] = plot_dir(chnk_plot_axis, chnkr, sol, zk, direction)

    addpath('../src');
    kvec = zk .* [cos(direction); sin(direction)];
    nplot = 20;

    xtarg = linspace(-3,3,nplot); 
    ytarg = linspace(-3,3,nplot);
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

    h=pcolor(chnk_plot_axis ,xxtarg,yytarg,real(zztarg));
    set(h,'EdgeColor','none');
    % colormap(chnk_plot_axis, redblue);
    colormap(chnk_plot_axis);
    caxis([-maxu,maxu]);
    % quick fix
    set(gcf,'Visible', 'off');
    % set axis 
    axis(chnk_plot_axis, [-3 3 -3 3]);
end