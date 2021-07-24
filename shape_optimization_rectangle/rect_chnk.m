function [chnkr, zero_loc] = rect_chnk(width, show_plot)
    % INPUT: width of chunker; (OPTIONAL: whether show plot)
    % OUTPUT: chnkr object, chunker id containing 0

    height = 1.0/width;

    verts = [[-width/2 0]; [width/2 0]; ...
        [width/2 height]; [-width/2 height]];

    cparams = []; cparams.eps = 1.0e-5;
    pref = []; pref.k = 16;
    chnkr = chunkerpoly(verts', cparams, pref);
    chebabs = [2,5];
    assert(checkadjinfo(chnkr) == 0);
    refopts = []; refopts.maxchunklen = pi/chebabs(2)/2;
    chnkr = chnkr.refine(refopts); chnkr = chnkr.sort();

    [rn,dn,d2n,dist,tn,ichn] = nearest(chnkr, [0 0], 1:chnkr.nch);
    zero_loc = ichn;

    if nargin > 1 & show_plot
        % plot geometry and data
        figure(1)
        clf
        plot(chnkr,'-b')
        hold on
        quiver(chnkr,'r')
        axis equal
    end

end