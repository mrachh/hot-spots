function vertices = compute_polygon_vertices(angles, rads)
    vertices = [cos(angles).*rads; sin(angles).*rads];
end