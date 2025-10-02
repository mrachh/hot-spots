function [init_rads, angles] = initialize_circle(n, ycenter)
    
        if nargin < 2
            ycenter = 0.98;
        end
        angles = initialize_angles(n);
    
        init_rads = zeros(1,n);
        for k = 1:n
            theta = angles(k);
            % dx = cos(theta);
            dy = sin(theta);
            a = 1;
            b = -2*ycenter*dy;
            c = ycenter^2 - 1;
    
            tsol = roots([a b c]);
            tsol = tsol(tsol > 0);
    
            if isempty(tsol)
                init_rads(k) = NaN;
            else
                init_rads(k) = min(tsol);
            end
        end
    end
    