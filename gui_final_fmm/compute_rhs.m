function [rhs] = compute_rhs(chnkr, direction, zk)
    addpath('../src');

    kvec = zk .* [cos(direction); sin(direction)];
    rhs = -planewave(kvec(:),chnkr.r(:,:)); rhs = rhs(:);
    
end
