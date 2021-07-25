function res = rectangle(width)
    addpath('../src');
    % INPUT: width size 1 real
    % OUTPUT: res size 1 real
    %     let lamb be the first eval and u be an evec
    %     res = a/b, where
    %         a = L-inf norm of grad u
    %         b = sqrt{lamb} * 2-norm(u)



    % Create chunker object
    [chnkr, zero_loc] = rect_chnk(width, show_plot);
    % Extract 16 real quadrature points around zero
    zero_quad_pts = chnkr.r(1, :, zero_loc);
    


end

