function [dvals,dzks] = get_grads_fmm(chnkr0, tn, ichn, sig, mu,zk, bie_norm, F, nv)


dvals = zeros(2,nv);
dzks  = zeros(2,nv);
for ii=1:nv
    for jj=1:2
        ind = jj + (ii-1)*2;

        i1 = ind;
        i2 = i1 + 2*nv;
        i3 = i1 + 4*nv;
        i4 = i1 + 2*nv + 4*nv;
        vfun = [i1,i2,i3,i4];

        [dzk,~,~,~,dval] = get_grad_v_fmm(chnkr0, tn, ichn, sig, mu, ...
                                             zk, bie_norm, F, vfun);
        dzks(jj,ii)  = dzk;
        dvals(jj,ii) = dval;

    end
end


end