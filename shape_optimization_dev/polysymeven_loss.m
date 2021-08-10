function [loss, new_chebab, ud_inf, max_grad_loc] = polysymeven_loss(weight, chebabs, figure_id)
    addpath('../src');
    % INPUT: width size 1 real
    % OUTPUT: res size 1 real
    %     let lamb be the first eval and u be an evec
    %     res = a/b, where
    %         a = L-inf norm of grad u
    %         b = sqrt{lamb} * 2-norm(u)

    default_chebabs = [3 7];
    if nargin < 2
        chebabs = default_chebabs;
    end


    if nargin < 3
        figure_id = -1;
    end

    % Create chunker object
    [chnkr, center] = polysymeven_chnk(weight);

    
    try
        % fprintf('Finding eigenvalue ... ');
        start = tic; [zk, err_nullvec, sigma] = helm_dir_eig(chnkr, chebabs);
        fprintf('Time to find eigenvalue: %5.2e; ', toc(start));
        
        start = tic; [ud_inf, max_grad_loc] = max_grad(chnkr, zk, sigma, figure_id);

        start = tic; u_2 = int_u_2(chnkr, zk, sigma, center);
        fprintf('Time to compute 2-norm: %5.2e\n', toc(start));

        loss =  - ud_inf/(u_2 * (zk^2));
    catch
        warning('Provided chebabs did not work');
        start = tic; [zk, err_nullvec, sigma] = helm_dir_eig(chnkr, default_chebabs);
        fprintf('Time to find eigenvalue: %5.2e; ', toc(start));
        
        start = tic; [ud_inf, max_grad_loc] = max_grad(chnkr, zk, sigma, figure_id);

        start = tic; u_2 = int_u_2(chnkr, zk, sigma, center);
        fprintf('Time to compute 2-norm: %5.2e\n', toc(start));

        loss =  - ud_inf/(u_2 * (zk^2));
    end

    cheb_left = 0.95;
    cheb_right = 1.05;
    new_chebab = [zk*cheb_left, zk*cheb_right];
    % fprintf('zk is %f', zk);

end

