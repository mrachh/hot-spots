function [rhs] = compute_rhs(chnkr, direction, zk)
    addpath('../src');

    kvec = zk .* [cos(direction); sin(direction)];
    fkern = @(s,t) chnk.helm2d.kern(zk,s,t,'c',1);
    opdims(1) = 1; opdims(2) = 1;
    opts = [];
    rhs = -planewave(kvec(:),chnkr.r(:,:)); rhs = rhs(:);
    
end