function [chnkr, center, verts] = chnk_poly(rs)
    % INPUT:  [r_1 r_2 ... r_M]
    % OUTPUT: chnkr object, center of chunker object
    % Vertices:
    % r_1 (cos(theta_1),sin(theta_1)), ... , r_M (cos(theta_M),sin(theta_M)),
    % where r_1,...,r_M are real numbers and 
    % theta_j = pi*(j-1)/(M-1).

    % MODIFIED: pi instead of 2pi

    [temp, M] = size(rs);
    num_verts = M;
    verts = zeros(2, num_verts);
    for i = 1:M 
        angle_i = pi*(i-1)/(M-1);
        verts(1,i) = rs(i)*cos(angle_i);
        verts(2,i) = rs(i)*sin(angle_i);
    end
    cparams = []; cparams.eps = 1.0e-5;
    pref = []; pref.k = 16;
    chnkr = chunkerpoly(verts, cparams, pref);
    assert(checkadjinfo(chnkr) == 0);
    refopts = []; refopts.maxchunklen = pi/7/2;
    chnkr = chnkr.refine(refopts); chnkr = chnkr.sort();

    center = sum(verts, 2)/num_verts;
end
