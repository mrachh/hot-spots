function [out] = find_targets(chnkr, targets)
    % given a chunkie object, find exterior points
    % xlim, ylim are fixed to be -3, 3

    addpath('../src');

    start = tic; in = chunkerinterior_fmm(chnkr,targets); t1 = toc(start);
    out = ~in;

    fprintf('%5.2e s : time to find points in domain\n',t1)


end
