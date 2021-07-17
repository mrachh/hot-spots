function [F] = compute_F(chnkr, zk)

    fkern = @(s,t) chnk.helm2d.kern(zk,s,t,'c',1);
    opdims(1) = 1; opdims(2) = 1;
    opts = [];

    dval = 0.5;
    opts_flam = [];
    opts_flam.flamtype = 'rskelf';
    F = chunkerflam(chnkr,fkern,dval,opts_flam);
end