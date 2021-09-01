function [chnkr, center] = chnk_rectangle(height)
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
    center = [0; height/2];

end
