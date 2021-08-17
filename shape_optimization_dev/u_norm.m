function u_q = u_norm(chnkr, zk, sigma, center, q)
    
    k = 16;
    % Maximum number of targets evaluated each time

    % Increase this if memory allows
    max_num_targeval = 8192;

    [xang,yang,wtot] = get_chunkie_quads(chnkr,center,k);
    targets = [xang yang]';
    [temp, num_targets] = size(targets);
    num_evals = ceil(num_targets/max_num_targeval);
    
    fkern = @(s,t) chnk.helm2d.kern(zk,s,t,'d',1);

    % uq is u^q; u_q means q-norm, i.e (uq)^(1/q)
    uq = 0;

    for i = 1:num_evals
        targind_start = (i-1) * max_num_targeval + 1;
        targind_end = min(i * max_num_targeval, num_targets);
        u = chunkerkerneval(chnkr,fkern,sigma,...
                targets(:, targind_start:targind_end));
        uq = uq + sum((abs(u).^q).*wtot(targind_start:targind_end));
    end

    u_q = uq^(1.0/q);


end