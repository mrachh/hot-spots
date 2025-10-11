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

        dvals_direction = dvals./norm(dvals);
        h_fdd = 1e-4;
        frads = rads + h_fdd.*dvals_direction;
        brads = rads - h_fdd.*dvals_direction;
        [fval, ~, ~, ~] = compute_obj_and_grads(frads, zk, ncheb, false, 1e-3, 1e-1);
        [bval, ~, ~, ~] = compute_obj_and_grads(brads, zk, ncheb, false, 1e-3, 1e-1);
        % minimize -ah^2+bh+c.
        coef_a = -(fval+bval-2*val)/(h_fdd^2);
        coef_b = (fval-bval)/(2*h_fdd);
        if coef_a>0&&coef_b>0
            stepsize = coef_b/(2*coef_a);
        else
            stepsize = norm(dvals);
        end

        rads_change = stepsize * dvals_direction;
        rads = rads + rads_change;

        iter = it;
        time = toc(tstart); 

        save(fullfile(savedir, sprintf('%d.mat', it)), ...
            'rads', 'val', 'zk', 'iter', 'time','stepsize','dvals','dzks');

        fprintf('itv3 %3d | val: %.8f | zk: %.8f | ||dvals||: %.8f | time: %.2fs | a: %.4f | step: %.4f\n', ...
                it, val, zk, norm(dvals), time, coef_a, stepsize);
            
        prev_zk = zk + dot(dzks, rads_change);
        cheb_factor = 0.05;

    end
end

function [rads, zk] = init_run(n, ycenter, zk0)
    rads   = initialize_circle(n, ycenter);
    zk     = zk0;
end
