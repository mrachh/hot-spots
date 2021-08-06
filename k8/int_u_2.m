function u_2 = int_u_2(chnkr, zk, sigma, center)
    
    k = 8;
    [xang,yang,wtot] = get_chunkie_quads(chnkr,center,k);
    targets = [xang yang]';
    fkern = @(s,t) chnk.helm2d.kern(zk,s,t,'d',1);
    % fprintf('Running chunkerkerneval on %d targets...\n', length(wtot));
    start = tic; u = chunkerkerneval(chnkr,fkern,sigma,targets);
    % fprintf('Time for chunkerkerneval: %5.2e\n', toc(start));
    u_2 = sqrt(sum((abs(u).^2).*wtot));


end