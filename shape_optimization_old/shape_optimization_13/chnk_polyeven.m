function [chnkr, center] = chnk_polyeven(rs, valid_verts)
    % INPUT:  [r_1 r_2 ... r_M]
    % OUTPUT: chnkr object
    % theta_j = (pi/2)*j/M
    % (0,0), r_1 (cos(theta_1),sin(theta_1)), ... , r_M (cos(theta_M),sin(theta_M)),
    % where r_1,...,r_M are real numbers and 
    % theta_j = pi*(j-1)/M.

    [~, M] = size(rs);
    num_verts = M * 2 ;
    rs_symmetric = zeros(1, num_verts);
    valid_verts_symmetric = zeros(1, num_verts);
    for i = 1:M 
        rs_symmetric(i) = rs(i);
        valid_verts_symmetric(i) = valid_verts(i);
    end
    for i = (M+1) : num_verts
        rs_symmetric(i) = rs(2*M + 1 - i);
        valid_verts_symmetric(i) = valid_verts(2*M + 1 - i);
    end
    
    [chnkr, center] = chnk_poly(rs_symmetric, valid_verts_symmetric);

end
