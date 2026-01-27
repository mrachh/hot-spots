function [val, dvals, zk, dzks] = compute_obj_and_grads(rads, cheb_center, ncheb, with_grads, cheb_width, cheb_width_fallback, flam_occ, angles)

    if nargin < 7 || isempty(flam_occ)
        flam_occ = 1000;
    end
    
    rads_size = length(rads);
    if nargin < 8 || isempty(angles)
        angles = initialize_angles(rads_size);
    end
    verts = compute_polygon_vertices(angles, rads);

    [chnkr, nv, tn, ichn] = build_chunker(verts);

    amin = cheb_center * (1-cheb_width);
    bmin = cheb_center * (1+cheb_width);

    success = false;
    while ~success
        try
            [val, zk, sig, mu, bie_norm, F] = obj_fun_flam(chnkr, tn, ichn, amin, bmin, ncheb, flam_occ);
            success = true;
        catch
            fprintf('Bracket [%g, %g] failed, expanding...\n', amin, bmin);
            amin = amin * (1-cheb_width_fallback);
            bmin = bmin * (1+cheb_width_fallback);
        end
    end

    if with_grads
        [dvals_cart, dzks_cart] = get_grads_fmm(chnkr, tn, ichn, sig, mu, zk, bie_norm, F, nv);
        dvals = cartesian_to_radial(dvals_cart, angles);
        dzks = cartesian_to_radial(dzks_cart, angles);
    else
        dvals = [];
        dzks  = [];
    end

end
