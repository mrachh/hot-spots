function [val, dvals, zk, dzks] = compute_obj_and_grads(verts, prev_zk, ncheb, with_grads)
    [chnkr, nv, tn, ichn] = build_chunker(verts);

    amin = prev_zk/2;
    bmin = prev_zk*2;

    success = false;
    while ~success
        try
            [val, zk, sig, mu, bie_norm, F] = obj_fun_flam(chnkr, tn, ichn, amin, bmin, ncheb);
            success = true;
        catch
            fprintf('Bracket [%g, %g] failed, expanding...\n', amin, bmin);
            amin = amin/2;
            bmin = bmin*2;
        end
    end

    if with_grads
        [dvals, dzks] = get_grads_fmm(chnkr, tn, ichn, sig, mu, zk, bie_norm, F, nv);
    else
        dvals = [];
        dzks  = [];
    end
end
