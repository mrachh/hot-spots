function u_2 = int_u_2(chnkr, zk, sigma, center)
    
    % k = 16;
    k = 64;
    % Maximum number of targets evaluated each time
    max_num_targeval = 8192;

    [xang,yang,wtot] = get_chunkie_quads(chnkr,center,k);
    targets = [xang yang]';
    [temp, num_targets] = size(targets);
    num_evals = ceil(num_targets/max_num_targeval);
    
    fkern = @(s,t) chnk.helm2d.kern(zk,s,t,'d',1);
    u2_squared = 0;

    for i = 1:num_evals
        targind_start = (i-1) * max_num_targeval + 1;
        targind_end = min(i * max_num_targeval, num_targets);
        u = chunkerkerneval(chnkr,fkern,sigma,...
                targets(:, targind_start:targind_end));
        u2_squared = u2_squared + sum((abs(u).^2).*wtot(targind_start:targind_end));
    end

    u_2 = sqrt(u2_squared);


end