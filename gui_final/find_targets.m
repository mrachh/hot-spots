function [out] = find_targets(chnkr)
    % given a chunkie object, find exterior points
    % xlim, ylim are fixed to be -3, 3

    addpath('../src');

    XLO = -3;
    XHI = 3;
    YLO = -3;
    YHI = 3;
    NPLOT = 250;

    xtarg = linspace(XLO,XHI,NPLOT); 
    ytarg = linspace(YLO,YHI,NPLOT);
    [xxtarg,yytarg] = meshgrid(xtarg,ytarg);
    targets = zeros(2,length(xxtarg(:)));
    targets(1,:) = xxtarg(:); targets(2,:) = yytarg(:);

    start = tic; in = chunkerinterior(chnkr,targets); t1 = toc(start);
    out = ~in;

    fprintf('%5.2e s : time to find points in domain\n',t1)


end