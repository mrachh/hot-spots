function [isconvex, idx_conv] = check_convex(rs, idx)

    if nargin < 2
        idx = ones(size(rs));
    end

    % Compute vertices on the convex hull
    [~, M] = size(rs);
    num_verts = sum(idx);
    verts = zeros(2, num_verts);
    j = 1;
    for i = 1:M 
        if idx(i)
            angle_i = 2*pi*(i-1)/M;
            verts(1,j) = rs(i)*cos(angle_i);
            verts(2,j) = rs(i)*sin(angle_i);
            j = j + 1;
        end
    end
    [idxidx, ~] = convhull(verts');
    idx_conv = zeros(size(rs));
    for i = 1:length(idxidx)
        idx_conv(idxidx(i)) = 1;
    end

    isconvex = true;
    for i = 1:M 
        isconvex = idx(i)==idx_conv(i);
    end

%     [~, num_rs] = size(rs);

%     % Compute the vertices that needs to be checked
%     verts = nan(num_verts, 2);
%     angle = 2 * pi/num_rs;
%     for i = 1:num_verts
%         angle_i = (i-1)*angle;
%         r = rs(i);
%         if r<=0
%             isconvex = false;
%             break;
%         end
%         x_i = cos(angle_i)*r;
%         y_i = sin(angle_i)*r;
%         verts(i,1) = x_i;
%         verts(i,2) = y_i;
%     end

%     if isconvex
%         for i = 1:num_verts
%             if ~ isconvex
%                 break;
%             end
%             % compute angle i-i+1-i+2
%             i_0 = mod(i-1, num_verts)+1;
%             i_1 = mod(i, num_verts)+1;
%             i_2 = mod(i+1, num_verts)+1;
%             v1 = verts(i_0,:) - verts(i_1,:);
%             v2 = verts(i_2,:) - verts(i_1,:);
%             x1 = v1(1);
%             y1 = v1(2);
%             x2 = v2(1);
%             y2 = v2(2);
%             angle = - atan2(x1*y2 - x2*y1, x1*x2 + y1*y2);
%             angle = wrapTo2Pi(angle);
%             isconvex = isconvex & (angle <= pi);
%         end
%     end

%     % Convexify if not convex
%     if ~ isconvex
%         warning('Shape has been convexified')
%         [conv_vert_id, ~] = convhull(verts);
%         num_conv_verts = length(conv_vert_id);

%         % conv_vert_id has the following form:
%         % 1 - 2 - 3 - 4 - 1

%         for i  = 1:(num_conv_verts - 1)
%             conv_start = conv_vert_id(i);
%             conv_end = conv_vert_id(i+1);
%             x1 = verts(conv_end,1);
%             y1 = verts(conv_end,2);
%             x2 = verts(conv_start,1);
%             y2 = verts(conv_start,2);
%             % Convexify everything between conv_start and conv_end
%             if conv_start < conv_end
%                 for j = conv_start + 1:conv_end - 1
%                     rs_conv(j) = convexify_single_vert(x1,y1,x2,y2,j,num_verts);
%                 end
%             else
%                 for j = conv_start + 1:num_verts
%                     rs_conv(j) = convexify_single_vert(x1,y1,x2,y2,j,num_verts);
%                 end

%                 for j = 1:conv_end - 1
%                     rs_conv(j) = convexify_single_vert(x1,y1,x2,y2,j,num_verts);
%                 end
%             end
%         end

%         fprintf('Convexified weights')
%         rs_conv


%     end

% end

% function r_res = convexify_single_vert(x1,y1,x2,y2,j,num_verts)
%     % put vertex j on the line segment connecting x1,y1 and x2,y2
%     ang = (j-1)*2*pi/num_verts;
%     sang = sin(ang);
%     cang = cos(ang);
%     r_res = (x2*y1-x1*y2)/...
%         (sang*x2+cang*y1-sang*x1-cang*y2);
% end