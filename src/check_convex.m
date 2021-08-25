function isconvex = check_convex(rs, vert_type, valid_verts)

% Assume an even number of vertices
    if nargin < 3
        error('valid verts not specified')
    end
    
    isconvex = true;


    if strcmp(vert_type, 'even')
        [~, M] = size(rs);
        num_verts = M * 2 ;
        rs_symmetric = zeros(1, num_verts);
        valid_verts_symmetric = zeros(1, num_verts);
        for i = 1:M 
            rs_symmetric(i) = rs(i);
            valid_verts_symmetric(i) = valid_verts(i);
        end
        for i = (M+1) : num_verts
            rs_symmetric(i) = rs(2*M + 1 - i);
            valid_verts_symmetric(i) = valid_verts(2*M + 1 - i);
        end
        rs = rs_symmetric;
        valid_verts = valid_verts_symmetric;
    end
    
    [~, num_rs] = size(rs);
    num_verts = num_rs;
    num_valid_verts = sum(valid_verts);

    % Compute the vertices that needs to be checked
    verts = nan(num_valid_verts, 2);
    angle = pi/(num_rs - 1);
    valid_vert_idx = 1;
    for i = 1:num_verts
        if valid_verts(i)
            angle_i = (i-1)*angle;
            r = rs(min(i,num_rs));
            if r<=0
                isconvex = false;
                break;
            end
            x_i = cos(angle_i)*r;
            y_i = sin(angle_i)*r;
            verts(valid_vert_idx,1) = x_i;
            verts(valid_vert_idx,2) = y_i;
            valid_vert_idx = valid_vert_idx + 1;
        end
    end

    if isconvex
        for i = 1:(num_valid_verts-2)
            if ~ isconvex
                break;
            end
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


end
