function [chnkr, center] = polysymodd_chnk(rs, show_plot)
    % INPUT:  [r_1 r_2 ... r_M]
    % OUTPUT: chnkr object
    % theta_j = (pi/2)*j/M
    % (0,0), r_1 (cos(theta_1),sin(theta_1)), ... , r_M (cos(theta_M),sin(theta_M)),
    % where r_1,...,r_M are real numbers and 
    % theta_j = pi*(j-1)/M.

    [temp, M] = size(rs);
    num_verts = M * 2 - 1;
    rs_symmetric = zeros(num_verts);
    for i = 1:M 
        rs_symmetric(i) = rs(i);
    end
    for i = (M+1) : num_verts
        rs_symmetric(i) = rs(2*M - i);
    end
    if nargin > 1
        [chnkr, center] = poly_chnk(rs_symmetric, show_plot);
    else
        [chnkr, center] = poly_chnk(rs_symmetric);
    end

end
