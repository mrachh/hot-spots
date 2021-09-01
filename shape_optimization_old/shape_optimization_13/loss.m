function [loss, chebabs, zk] = loss(weight, loss_params, chebabs, valid_verts)
    addpath('../src');
    % INPUT: weight, eigenvalue interval [a b] (OPTIONAL)
    % OUTPUT: loss, eigenvalue interval, 

    cheb_left = 0.95;
    cheb_right = 1.05;

    %debug
    if nargin < 4
        error('valid_verts not provided')
    end

    % Reads loss parameters
    default_chebabs = loss_params.default_chebabs;
    q = str2double(loss_params.unorm_ord);
    p = str2double(loss_params.udnorm_ord);
    if isnan(q) or isnan(p)
        error('Invalid loss parameters')
    end
    if isinf(q)
        errors('unorm_ord = inf not supported')
    end
    beta = 1/2 - 1/(2*p) + 1/(q);


    if isnan(chebabs)
        chebabs = default_chebabs;
    end

    % Create chunker object
    [chnkr, center] = loss_params.chnk_fun(weight, valid_verts);

    
    try
        start = tic; [zk, err_nullvec, sigma] = find_first_eig(chnkr, chebabs);
        fprintf('Time to find eigenvalue: %5.2e; ', toc(start));
        
        start = tic; [ud_p] = ud_norm(chnkr, zk, sigma, p);

        start = tic; u_q = u_norm(chnkr, zk, sigma, center, q);
        fprintf('Time to compute 2-norm: %5.2e\n', toc(start));

        loss =  - ud_p/(u_q * (zk^(2*beta)));
    catch
        start = tic; [zk, err_nullvec, sigma] = find_first_eig(chnkr, default_chebabs);
        fprintf('Time to find eigenvalue: %5.2e; ', toc(start));
        
        start = tic; [ud_p] = ud_norm(chnkr, zk, sigma, p);

        start = tic; u_q = u_norm(chnkr, zk, sigma, center, q);
        fprintf('Time to compute 2-norm: %5.2e\n', toc(start));

        loss =  - ud_p/(u_q * (zk^(2*beta)));
    end

    % Update eigenvalue interval
    chebabs = [zk*cheb_left, zk*cheb_right]

end

