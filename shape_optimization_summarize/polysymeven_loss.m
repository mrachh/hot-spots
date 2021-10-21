function [loss, new_chebab, zk] = polysymeven_loss(weight, chebabs)
    addpath('../src');
    % INPUT: weight, eigenvalue interval [a b] (OPTIONAL)
    % OUTPUT: loss, eigenvalue interval, 


    default_chebabs = [1 6];
    cheb_left = 0.95;
    cheb_right = 1.05;

    if nargin < 2
        chebabs = default_chebabs;
    end

    % Create chunker object
    [chnkr, center] = polysymeven_chnk(weight);

    
    try
        start = tic; [zk, err_nullvec, sigma] = find_first_eig(chnkr, chebabs);
        fprintf('Time to find eigenvalue: %5.2e; ', toc(start));
        
        start = tic; [ud_inf] = gradu_at_zero(chnkr, zk, sigma);

        start = tic; u_2 = u_two_norm(chnkr, zk, sigma, center);
        fprintf('Time to compute 2-norm: %5.2e\n', toc(start));

        loss =  - ud_inf/(u_2 * (zk^2));
    catch
        warning('Provided chebabs did not work');
        start = tic; [zk, err_nullvec, sigma] = find_first_eig(chnkr, default_chebabs);
        fprintf('Time to find eigenvalue: %5.2e; ', toc(start));
        
        start = tic; [ud_inf] = gradu_at_zero(chnkr, zk, sigma);

        start = tic; u_2 = u_two_norm(chnkr, zk, sigma, center);
        fprintf('Time to compute 2-norm: %5.2e\n', toc(start));

        loss =  - ud_inf/(u_2 * (zk^2));
    end

    % Update eigenvalue interval
    new_chebab = [zk*cheb_left, zk*cheb_right];

end

