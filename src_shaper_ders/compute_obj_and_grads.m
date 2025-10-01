function [val, dvals, zk, dzks] = compute_obj_and_grads(verts, amin, bmin, ncheb, with_grads)
    [chnkr, nv, tn, ichn] = build_chunker(verts);
    [val, zk, sig, mu, bie_norm, F] = obj_fun_flam(chnkr, tn, ichn, amin, bmin, ncheb);
    if with_grads
        [dvals, dzks] = get_grads_fmm(chnkr, tn, ichn, sig, mu, zk, bie_norm, F, nv);
    else
        dvals = [];
        dzks  = [];
    end
end
