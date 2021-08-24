function isconvex = check_convex(rs)

% Assume an even number of vertices
    [~, num_rs] = size(rs);
    num_verts = num_rs+ 1;

    % Compute the vertices that needs to be checked
    verts = nan(num_verts, 2);
    angle = pi/(2*num_rs - 1);
    for i = 1:num_verts
        angle_i = (i-1)*angle;
        x_i = cos(angle_i)*rs(min(i,num_rs));
        y_i = sin(angle_i)*rs(min(i,num_rs));
        verts(i,1) = x_i;
        verts(i,2) = y_i;
    end

    isconvex = true;

    for i = 1:(num_verts-2)
        % compute angle i-i+1-i+2
        v1 = verts(i,:) - verts(i+1,:);
        v2 = verts(i+2,:) - verts(i+1,:);
        x1 = v1(1);
        y1 = v1(2);
        x2 = v2(1);
        y2 = v2(2);
        angle = - atan2(x1*y2 - x2*y1, x1*x2 + y1*y2);
        angle = wrapTo2Pi(angle);
        isconvex = isconvex & (angle < pi);
    end

end
