function [chunker, center] = chunk_polygon(verts)
    % verts of shape 2 by M must be oriented counter-clockwise
        cparams = []; 
        cparams.eps = 1.0e-5;
        pref = []; 
        pref.k = 16;
        chunker = chunkerpoly(verts, cparams, pref);
        assert(checkadjinfo(chunker) == 0);
        refopts = []; 
        refopts.maxchunklen = pi/7/2;
        chunker = chunker.refine(refopts); 
        chunker = chunker.sort();
        center = mean(verts, 2);
end