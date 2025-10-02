function run_gradient_descent(n, ncheb, ycenter, maxiter, stepsize, zk0, savefile, resume)

    if resume && exist(savefile, 'file')
        S = load(savefile);
        rads    = S.rads;
        angles  = S.angles;
        prev_zk = S.prev_zk;
        start_it = S.iter + 1;
        vals = S.vals;
        zks  = S.zks;
        if isfield(S,'times')
            times = S.times;
        else
            times = [];
        end
        fprintf('Resuming from iteration %d...\n', S.iter);
    else
        angles   = initialize_angles(n);
        rads     = initialize_circle(n, ycenter);
        prev_zk  = zk0;
        start_it = 1;
        vals = [];
        zks  = [];
        times = [];
    end

    fprintf('Iter |   val        |   zk         |   norm(drads)\n');
    fprintf('-----------------------------------------------\n');

    for it = start_it:maxiter
        t_iter = tic;

        verts = compute_polygon_vertices(angles, rads);
        [val, dvals, zk, dzks] = compute_obj_and_grads(verts, prev_zk, ncheb, true);
        drads = cartesian_to_radial(dvals, angles);

        fprintf('%3d  | %.8f | %.8f | %.8f\n', it, val, zk, norm(drads));

        rads = rads + stepsize * drads;
        prev_zk = zk;

        vals(end+1)  = val;
        zks(end+1)   = zk;
        times(end+1) = toc(t_iter);

        iter = it;
        save(savefile, 'rads', 'angles', 'prev_zk', 'iter', 'vals', 'zks', 'times');
    end

    verts_final = compute_polygon_vertices(angles, rads);
    figure; axis equal; hold on;
    plot([verts_final(1,:) verts_final(1,1)], [verts_final(2,:) verts_final(2,1)], 'r-o');
    title(sprintf('Final polygon after %d iterations', maxiter));
    xlabel('x'); ylabel('y');
end
