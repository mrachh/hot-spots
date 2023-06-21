function [nice_verts] = preproc_verts(verts)
    % preprocess the vertices
    % vertices are of shape 2*n

    nice_verts = flipud(polyshape(verts').Vertices)';

end