function run_gradient_descent(n, ncheb, ycenter, maxiter, stepsize, zk0, savedir, resume)
    clearvars -except n ncheb ycenter maxiter stepsize zk0 savedir resume;
    clc;

    addpath ../src
    addpath ../src_shaper_ders/
    cluster_startup;

    if ~exist(savedir, 'dir')
        mkdir(savedir);
    end

    if resume
        matfiles = dir(fullfile(savedir, '*.mat'));
        if ~isempty(matfiles)
            [~, idx] = max([matfiles.datenum]);
            latest = fullfile(savedir, matfiles(idx).name);
            S = load(latest);
            rads    = S.rads;
            angles  = S.angles;
            prev_zk = S.zk;
            start_iter = S.iter + 1;
        else
            [rads, angles, prev_zk] = init_run(n, ycenter, zk0);
            start_iter = 1;
        end
    else
        delete(fullfile(savedir, '*.mat'));
        [rads, angles, prev_zk] = init_run(n, ycenter, zk0);
        start_iter = 1;
    end

    for it = start_iter:maxiter
        verts = compute_polygon_vertices(angles, rads);
        tstart = tic;
        [val, dvals, zk, dzks] = compute_obj_and_grads(verts, prev_zk, ncheb, true);
        tstep = toc(tstart);

        drads = cartesian_to_radial(dvals, angles);
        rads = rads + stepsize * drads(:).';

        iter = it;       % save iteration number
        time = tstep;    % save runtime

        save(fullfile(savedir, sprintf('%d.mat', it)), ...
            'angles', 'rads', 'val', 'zk', 'iter', 'time');

        fprintf('%3d | %.8f | %.8f | %.8f\n', it, val, zk, norm(drads));

        prev_zk = zk;
    end
end

function [rads, angles, zk] = init_run(n, ycenter, zk0)
    rads   = initialize_circle(n, ycenter);
    angles = initialize_angles(n);
    zk     = zk0;
end
