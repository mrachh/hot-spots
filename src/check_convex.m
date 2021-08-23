function isconvex = check_convex(rs)

% Assume an even number of vertices
    [~, num_rs] = size(rs);
    num_verts = num_rs+ 2;

    % Compute the vertices that needs to be checked
    verts = nan(num_verts, 2);
    angle = pi/(2*num_rs - 1);
    for i = 2:(num_verts - 1)
        angle_i = (i-2)*angle;
        x_i = cos(angle_i)*rs(i-1);
        y_i = sin(angle_i)*rs(i-1);
        verts(i+1,1) = x_i;
        verts(i+1,2) = y_i;
    end
    verts(1,:) = [0;0];
    verts(num_verts,:) = verts(num_verts - 1,:);

    isconvex = true;

    for i = 1:(num_verts-2)
        % compute angle i-i+1-i+2
        v1 = verts(i,:) - verts(i+1,:);
        v2 = verts(i+2,:) - verts(i+1,:);
        x1 = v1(1);
        y1 = v1(2);
        x2 = v2(1);
        y2 = v2(2);
        if y2==0
            angle = atan2(x1, y1);
        elseif y1==0
            angle = - atan2(x2, y2);
        else
            angle = - atan2(x1*x2 + y1*y2, x1*y2 - x2*y1);
        end
        angle
        isconvex = isconvex & (angle < pi) & (angle > 0);
    end

end
