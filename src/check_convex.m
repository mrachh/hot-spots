function [isconvex, rs_conv] = check_convex(rs)
    
    % convex_tol = 1e-15;

    isconvex = true;

    [~, num_rs] = size(rs);
    num_verts = num_rs;
    rs_conv = rs;

    % Compute the vertices that needs to be checked
    verts = nan(num_verts, 2);
    angle = 2 * pi/num_rs;
    for i = 1:num_verts
        angle_i = (i-1)*angle;
        r = rs(i);
        if r<=0
            isconvex = false;
            break;
        end
        x_i = cos(angle_i)*r;
        y_i = sin(angle_i)*r;
        verts(i,1) = x_i;
        verts(i,2) = y_i;
    end

    if isconvex
        for i = 1:num_verts
            if ~ isconvex
                break;
            end
            % compute angle i-i+1-i+2
            i_0 = mod(i-1, num_verts)+1;
            i_1 = mod(i, num_verts)+1;
            i_2 = mod(i+1, num_verts)+1;
            v1 = verts(i_0,:) - verts(i_1,:);
            v2 = verts(i_2,:) - verts(i_1,:);
            x1 = v1(1);
            y1 = v1(2);
            x2 = v2(1);
            y2 = v2(2);
            angle = - atan2(x1*y2 - x2*y1, x1*x2 + y1*y2);
            angle = wrapTo2Pi(angle);
            isconvex = isconvex & (angle <= pi);
        end
    end

    % Convexify if not convex
    if ~ isconvex

        % Two pass convexification

        % First Pass
        for i = 1:num_verts
            % compute angle i-i+1-i+2
            i_0 = mod(i-1, num_verts)+1;
            i_1 = mod(i, num_verts)+1;
            i_2 = mod(i+1, num_verts)+1;
            v1 = verts(i_0,:) - verts(i_1,:);
            v2 = verts(i_2,:) - verts(i_1,:);
            x1 = v1(1);
            y1 = v1(2);
            x2 = v2(1);
            y2 = v2(2);
            angle = - atan2(x1*y2 - x2*y1, x1*x2 + y1*y2);
            angle = wrapTo2Pi(angle);
            if angle > pi + 1e-15
                % angle for r_i+1
                ang = (i_1-1)*2*pi/num_verts;
                sang = sin(ang);
                cang = cos(ang);
                x1 = verts(i_2,1);
                y1 = verts(i_2,2);
                x2 = verts(i_0,1);
                y2 = verts(i_0,2);
                r = (x2*y1-x1*y2)/...
                    (sang*x2+cang*y1-sang*x1-cang*y2);
                verts(i_1,1) = r*cang;
                verts(i_1,2) = r*sang;
            end
        end

        % Second Pass
        for i = num_verts:(-1):1
            % compute angle i-i+1-i+2
            i_0 = mod(i-1, num_verts)+1;
            i_1 = mod(i, num_verts)+1;
            i_2 = mod(i+1, num_verts)+1;
            v1 = verts(i_0,:) - verts(i_1,:);
            v2 = verts(i_2,:) - verts(i_1,:);
            x1 = v1(1);
            y1 = v1(2);
            x2 = v2(1);
            y2 = v2(2);
            angle = - atan2(x1*y2 - x2*y1, x1*x2 + y1*y2);
            angle = wrapTo2Pi(angle);
            if angle > pi + 1e-15
                % angle for r_i+1
                ang = (i_1-1)*2*pi/num_verts;
                sang = sin(ang);
                cang = cos(ang);
                x1 = verts(i_2,1);
                y1 = verts(i_2,2);
                x2 = verts(i_0,1);
                y2 = verts(i_0,2);
                r = (x2*y1-x1*y2)/...
                    (sang*x2+cang*y1-sang*x1-cang*y2);
                verts(i_1,1) = r*cang;
                verts(i_1,2) = r*sang;
            end
        end

        % Iterative convexification
        % convex_err = 1;
        % while convex_err > convex_tol

        %     convex_err = 0;

        %     for i = 1:num_verts
        %         % compute angle i-i+1-i+2
        %         i_0 = mod(i-1, num_verts)+1;
        %         i_1 = mod(i, num_verts)+1;
        %         i_2 = mod(i+1, num_verts)+1;
        %         v1 = verts(i_0,:) - verts(i_1,:);
        %         v2 = verts(i_2,:) - verts(i_1,:);
        %         x1 = v1(1);
        %         y1 = v1(2);
        %         x2 = v2(1);
        %         y2 = v2(2);
        %         angle = - atan2(x1*y2 - x2*y1, x1*x2 + y1*y2);
        %         angle = wrapTo2Pi(angle);
        %         if angle > pi + 1e-15
        %             % angle for r_i+1
        %             convex_err = convex_err + angle - pi;
        %             ang = (i_1-1)*2*pi/num_verts;
        %             sang = sin(ang);
        %             cang = cos(ang);
        %             x1 = verts(i_2,1);
        %             y1 = verts(i_2,2);
        %             x2 = verts(i_0,1);
        %             y2 = verts(i_0,2);
        %             r = (x2*y1-x1*y2)/...
        %                 (sang*x2+cang*y1-sang*x1-cang*y2);
        %             verts(i_1,1) = r*cang;
        %             verts(i_1,2) = r*sang;
        %         end
        %     end
        %     disp(convex_err)
        % end



        %Convert verts to rs
        % scatter(verts(:,1),verts(:,2))
        % verts
        angle = 2 * pi/num_rs;
        for i = 1:num_verts
            angle_i = (i-1)*angle;
            if cos(angle_i)~=0
                rs_conv(i) = verts(i,1) / cos(angle_i);
            else
                rs_conv(i) = verts(i,2) / sin(angle_i);
            end
        end


    end

end
