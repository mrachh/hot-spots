function [loss, zk, ud_inf] = rect_loss(height, figure_id)
    addpath('../src');
    % INPUT: width size 1 real
    % OUTPUT: res size 1 real
    %     let lamb be the first eval and u be an evec
    %     res = a/b, where
    %         a = L-inf norm of grad u
    %         b = sqrt{lamb} * 2-norm(u)



    chebabs = [2,5];

    if nargin < 2
        figure_id = -1;
    end

    % Create chunker object
    chnkr = rect_chnk(height);
    
    % fprintf('Finding eigenvalue ...\n');
    start = tic; [zk, err_nullvec, sigma] = helm_dir_eig(chnkr, chebabs);
    % fprintf('Time to find eigenvalue: %5.2e\n', toc(start));
    
    % fprintf('Finding ymax_final ...\n');
    start = tic; ud_inf = max_grad(chnkr, zk, sigma, figure_id);
    % fprintf('Time to find ymax_final: %5.2e\n', toc(start));


    center = [0 height/2];
    u_2 = int_u_2(chnkr, zk, sigma, center);
    
    loss =  - ud_inf/(u_2 * (zk^2));


end

