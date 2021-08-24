function [ud_inf] = gradu_at_zero(chnkr, zk, sigma)

    % Computes gradient at the origin

    dudncomputed = helm_dprime(zk,chnkr,sigma);
    r = chnkr.r(:);
    r = reshape(r,[2,chnkr.k*chnkr.nch]);
    wts = weights(chnkr);
    wts = reshape(wts,[chnkr.k*chnkr.nch,1]);
    rint = sum(dudncomputed.*wts);
    rint = rint/abs(rint);
    y = real(dudncomputed./rint);

    % Find the chunk closest to the origin
    [rn,dn,d2n,dist,tn,ichind] = ...
        nearest(chnkr, [0 0], 1:chnkr.nch);

    mat = lege.matrin(chnkr.k, tn);
    y = reshape(y,[chnkr.k,chnkr.nch]);
    ud_inf = dot(mat,y(:,ichind));

end