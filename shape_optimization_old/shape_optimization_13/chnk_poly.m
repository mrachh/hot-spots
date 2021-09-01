function [chnkr, center] = chnk_poly(rs,valid_verts)
    % INPUT:  [r_1 r_2 ... r_M]
    % OUTPUT: chnkr object, center of chunker object
    % Vertices:
    % r_1 (cos(theta_1),sin(theta_1)), ... , r_M (cos(theta_M),sin(theta_M)),
    % where r_1,...,r_M are real numbers and 
    % theta_j = pi*(j-1)/(M-1).

    [temp, M] = size(rs);
    num_verts = M;
    num_valid_verts = sum(valid_verts);
    verts = zeros(2, num_valid_verts);
    verts_idx = 1;
    for i = 1:M 
        if valid_verts(i)
            angle = pi*(i-1)/(M-1);
            verts(1,verts_idx) = rs(i)*cos(angle);
            verts(2,verts_idx) = rs(i)*sin(angle);
            verts_idx = verts_idx + 1;
        end
    end
    cparams = []; cparams.eps = 1.0e-5;
    pref = []; pref.k = 16;
    chnkr = chunkerpoly(verts, cparams, pref);
    assert(checkadjinfo(chnkr) == 0);
    refopts = []; refopts.maxchunklen = pi/7/2;
    chnkr = chnkr.refine(refopts); chnkr = chnkr.sort();

    center = sum(verts, 2)/num_verts;

end
