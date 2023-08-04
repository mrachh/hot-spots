function [chunker, center] = chunk_polygon(verts, maxchunklen)
    % verts of shape 2 by M must be oriented counter-clockwise
    if nargin <2
        maxchunklen = 0.2;
    end
    cparams = []; 
    cparams.eps = 1.0e-5;
    pref = []; 
    pref.k = 16;
    chunker = chunkerpoly(verts, cparams, pref);
    assert(checkadjinfo(chunker) == 0);
    refopts = []; 
    refopts.maxchunklen = maxchunklen;
    refopts.nchmax = Inf;
    chunker = chunker.refine(refopts); 
    chunker = chunker.sort();
    center = mean(verts, 2);
end