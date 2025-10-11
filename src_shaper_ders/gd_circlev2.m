function gd_circlev2(n, ncheb, ycenter, maxiter, stepsize, zk0, savedir, resume)
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
            prev_zk = S.zk;
            start_iter = S.iter + 1;
        else
            [rads, prev_zk] = init_run(n, ycenter, zk0);
            start_iter = 1;
        end
    else
        delete(fullfile(savedir, '*.mat'));
        [rads, prev_zk] = init_run(n, ycenter, zk0);
        start_iter = 1;
    end

    cheb_factor = 0.5;
    cheb_factor_fallback = 0.5;

    for it = start_iter:maxiter
        tstart = tic;
        [val, dvals, zk, dzks] = compute_obj_and_grads(rads, prev_zk, ncheb, true, cheb_factor, cheb_factor_fallback);
        tstep = toc(tstart);

        % end of my new code
        rads_change = stepsize * dvals;
        rads = rads + rads_change;

        iter = it;       % save iteration number
        time = tstep;    % save runtime

        fprintf('itv2 %3d | val: %.8f | zk: %.8f | ||dvals||: %.8f | time: %.2fs| step: %.4f\n', ...
                iter, val, zk, norm(dvals), time, stepsize);

        fprintf('%3d | %.8f | %.8f | %.8f | %.2fs\n', it, val, zk, norm(dvals), time);

        prev_zk = zk + dot(dzks, rads_change);
        cheb_factor = 0.05;

    end
end

function [rads, zk] = init_run(n, ycenter, zk0)
    rads   = initialize_circle(n, ycenter);
    zk     = zk0;
end
