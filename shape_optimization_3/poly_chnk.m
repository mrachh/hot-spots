function [chnkr, center] = poly_chnk(rs, show_plot)
    % INPUT:  [r_1 r_2 ... r_M]
    % OUTPUT: chnkr object
    % r_1 (cos(theta_1),sin(theta_1)), ... , r_M (cos(theta_M),sin(theta_M)),
    % where r_1,...,r_M are real numbers and 
    % theta_j = pi*(j-1)/(M-1).

    [temp, M] = size(rs);
    num_verts = M;
    verts = zeros(2, num_verts);
    for i = 1:M 
        angle = pi*(i-1)/(M-1);
        verts(1,i) = rs(i)*cos(angle);
        verts(2,i) = rs(i)*sin(angle);
    end

    cparams = []; cparams.eps = 1.0e-5;
%%%%%%%%%%%%%%%%%%%%
    pref = []; pref.k = 30;
%%%%%%%%%%%%%%%%%%
    chnkr = chunkerpoly(verts, cparams, pref);
    assert(checkadjinfo(chnkr) == 0);
    refopts = []; refopts.maxchunklen = pi/6/2;
    chnkr = chnkr.refine(refopts); chnkr = chnkr.sort();


    if nargin > 1 & show_plot
        % plot geometry and data
        figure(1)
        clf
        plot(chnkr,'-b')
        hold on
        quiver(chnkr,'r')
        axis equal
    end

    center = sum(verts, 2)/num_verts;

end
