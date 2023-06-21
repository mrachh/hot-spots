function [uscat] = compute_uscat(chnkr, zk, sol, out, targets)
    addpath('../src');
    fkern = @(s,t) chnk.helm2d.kern(zk,s,t,'c',1);
    uscat = chunkerkerneval(chnkr,fkern,sol,targets);
end
