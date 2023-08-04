function [loss, chebabs, zk, ud_p, u_q] = compute_loss(verts, loss_params, chebabs, maxchunklen)
    % INPUT: weight, eigenvalue interval [a b] (OPTIONAL)
    % OUTPUT: loss, eigenvalue interval, 
    % Example:
    % loss_params = struct(...
    % 'default_chebabs',      [2 6], ...
    % 'udnorm_ord',              'inf', ...
    % 'unorm_ord',                  '2' ...
    % );


    cheb_left = 0.9;
    cheb_right = 1.1;

    % Reads loss parameters
    default_chebabs = loss_params.default_chebabs;
    q = str2double(loss_params.unorm_ord);
    p = str2double(loss_params.udnorm_ord);
    if isinf(q)
        errors('unorm_ord = inf not supported')
    end
    beta = 1/2 - 1/(2*p) + 1/(q);


    if nargin<3
        chebabs = default_chebabs;
    end
    % Create chunker object
    [chnkr, center] = chunk_polygon(verts, maxchunklen);

    
    try
        start = tic; [zk, err_nullvec, sigma] = find_first_eig(chnkr, chebabs);
        % fprintf('Time to find eigenvalue: %5.2e; ', toc(start));
        
        start = tic; [ud_p] = ud_origin(chnkr, zk, sigma);

        start = tic; u_q = u_norm(chnkr, zk, sigma, center, q);
        % fprintf('Time to compute 2-norm: %5.2e\n', toc(start));

        loss =  - ud_p/(u_q * (zk^(2*beta)));
    catch
        start = tic; [zk, err_nullvec, sigma] = find_first_eig(chnkr, default_chebabs);
        fprintf('Time to find eigenvalue: %5.2e; ', toc(start));
        
        start = tic; [ud_p] = ud_origin(chnkr, zk, sigma);

        start = tic; u_q = u_norm(chnkr, zk, sigma, center, q);
        fprintf('Time to compute 2-norm: %5.2e\n', toc(start));

        loss =  - ud_p/(u_q * (zk^(2*beta)));
    end

    % Update eigenvalue interval
    chebabs = [zk*cheb_left, zk*cheb_right];

end

