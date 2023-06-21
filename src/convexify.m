function result = convexify(angles, rads, conv_eps)
    % recompute the radii of a polygon using the convex hull
    % conv_eps is added to the flat piece
    result = rads;
    n = length(angles);
    vertices = compute_polygon_vertices(angles, rads);
    vertex_indices = convhull(vertices')
    num_support_vertices = length(vertex_indices)-1;
    for i = 1:num_support_vertices
        vertex_index = vertex_indices(i);
        next_vertex_index = vertex_indices(i+1);
        x1 = vertices(1,vertex_index);
        y1 = vertices(2,vertex_index);
        x2 = vertices(1,next_vertex_index);
        y2 = vertices(2,next_vertex_index);
        slope = (y2-y1)/(x2-x1);
        j_start = vertex_index+1;
        if next_vertex_index>vertex_index
            j_end = next_vertex_index-1;
        else
            j_end = next_vertex_index+n-1;
        end
        for j = j_start:j_end
            k = j;
            if k>n
                k = k-n;
            end
            angle = angles(k);
            k
            new_rad = (slope*x1-y1)/(slope*cos(angle)-sin(angle))+conv_eps;
            result(k) = new_rad;
        end
    end
end