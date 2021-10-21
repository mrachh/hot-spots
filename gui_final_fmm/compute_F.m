function [F,invtype] = compute_F(chnkr, zk)
    n = chnkr.k*chnkr.nch;
    invtype = 0;
    fkern = @(s,t) chnk.helm2d.kern(zk,s,t,'c',1);
    opdims(1) = 1; opdims(2) = 1;
    dval = 0.5;
    if (n<800) 
        invtype = 1;
    end
    if(invtype == 0)
        opts_flam = [];
        opts_flam.flamtype = 'rskelf';
        opts_flam.rank_or_tol = 1e-6;
        F = chunkerflam(chnkr,fkern,dval,opts_flam);
    else
        dmat = chunkermat(chnkr,fkern)+eye(n)*dval;
        F = inv(dmat);

    end
end
