function [verts, angles, rads] = initialize_polygon_vertices(num_vertices,bottom,a,b)
    % initializes a polygon with an ellipse
    % bottom controls the start and end angle
    % a,b are ellipse parameters
    angles = ((1+2*bottom)*pi/(num_vertices-1))*(0:num_vertices-1)-bottom*pi;
    rads = (cos(angles).^2/a^2+sin(angles).^2/b^2).^-0.5;
    rads = rads/mean(rads);
    verts = [cos(angles).*rads; sin(angles).*rads];
end