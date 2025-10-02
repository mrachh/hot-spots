function run_gradient_descent(n, ncheb, ycenter, maxiter, stepsize, zk0, savefile, resume)
    clearvars -except n ncheb ycenter maxiter stepsize zk0 savefile resume
    clc

    if resume && isfile(savefile)
        S = load(savefile);
        rads     = S.rads;
        vals     = S.vals;
        zks      = S.zks;
        iter     = S.iter;
        time_per_step = S.time_per_step;
    else
        rads     = initialize_circle(n, ycenter);
        vals     = [];
        zks      = [];
        iter     = 0;
        time_per_step = [];
    end

    angles = initialize_angles(n);

    for it = (iter+1):maxiter
        tstart = tic;
        verts = compute_polygon_vertices(angles, rads);
        [val, dvals, zk, dzks] = compute_obj_and_grads(verts, zk0, ncheb, true);

        drads = xy_to_radial(dvals, angles);
        rads  = rads + stepsize * drads;

        iter = it;
        vals(end+1) = val;
        zks(end+1)  = zk;
        step_time   = toc(tstart);
        time_per_step(end+1) = step_time;

        save(savefile, "rads", "vals", "zks", "iter", "time_per_step", "n");
        fprintf('%3d | %.8f | %.8f | %.8f | %.4fs\n', it, val, zk, norm(drads), step_time);
    end
end
