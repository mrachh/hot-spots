function [loss, zk, ud_inf, max_grad_loc] = polysymeven_loss(weight,chebabs, figure_id)
    addpath('../src');
    % INPUT: width size 1 real
    % OUTPUT: res size 1 real
    %     let lamb be the first eval and u be an evec
    %     res = a/b, where
    %         a = L-inf norm of grad u
    %         b = sqrt{lamb} * 2-norm(u)


    if nargin < 2
        chebabs = [1 6];
    end


    if nargin < 3
        figure_id = -1;
    end

    % Create chunker object
    [chnkr, center] = polysymeven_chnk(weight);
    
    % fprintf('Finding eigenvalue ...\n');
    start = tic; [zk, err_nullvec, sigma] = helm_dir_eig(chnkr, chebabs);
    fprintf('Time to find eigenvalue: %5.2e; ', toc(start));
    
    % fprintf('Finding ymax_final ...\n');
    start = tic; [ud_inf, max_grad_loc] = max_grad(chnkr, zk, sigma, figure_id);

    % fprintf('max grad location: %f\n',max_grad_loc);

    % fprintf('Computing 2-norm ...\n');
    start = tic; u_2 = int_u_2(chnkr, zk, sigma, center);
    fprintf('Time to compute 2-norm: %5.2e\n', toc(start));

    loss =  - ud_inf/(u_2 * (zk^2));


end

