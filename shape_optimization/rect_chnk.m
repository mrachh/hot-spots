function [chnkr] = rect_chnk(height, show_plot)
    % INPUT: width of chunker; (OPTIONAL: whether show plot)
    % OUTPUT: chnkr object


    width = 1.0;

    verts = [[-width*0.5 0]; [width*0.5 0]; ...
        [width*0.5 height]; [-width*0.5 height]];

    cparams = []; cparams.eps = 1.0e-5;
    pref = []; pref.k = 16;
    chnkr = chunkerpoly(verts', cparams, pref);
    assert(checkadjinfo(chnkr) == 0);
    refopts = []; refopts.maxchunklen = pi/5/2;
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

end
