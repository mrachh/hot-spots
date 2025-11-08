function gd_circlev4(n, ncheb, ycenter, maxiter, stepsize, zk0, savedir, resume)
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
            hinv   = eye(n);
            start_iter = S.iter + 1;
        else
            [rads, prev_zk, hinv] = init_run(n, ycenter, zk0);
            start_iter = 1;
        end
    else
        delete(fullfile(savedir, '*.mat'));
        [rads, prev_zk, hinv] = init_run(n, ycenter, zk0);
        start_iter = 1;
    end

    cheb_factor = 0.5;
    cheb_factor_fallback = 0.5;

    for it = start_iter:maxiter
        tstart = tic;
        [val, dvals, zk, dzks] = compute_obj_and_grads(rads, prev_zk, ncheb, true, cheb_factor, cheb_factor_fallback);
        if it>start_iter
            yv  = (dvals - prev_dvals)';
            sv  = rads_change';
            if abs(yv' * sv) < 1e-12
                rho = 0;
            else
                rho = 1 / (yv' * sv);
            end
            idm = eye(length(sv));
            hinv = (idm - rho * (sv * yv')) * hinv * (idm - rho * (yv * sv')) + rho * (sv * sv');
            search_direction = -(hinv * dvals(:))';
        else
            search_direction = dvals;
        end
        fallback_step_size = norm(search_direction);
        search_direction = search_direction./norm(search_direction);
        h_fdd = 1e-3;
        fbrads_change = h_fdd.*search_direction;
        zk_width = abs(dot(fbrads_change, dzks)/zk);
        frads = rads + fbrads_change;
        brads = rads - fbrads_change;
        [fval, ~, ~, ~] = compute_obj_and_grads(frads, zk, 8, false, zk_width*10, 1e-1);
        [bval, ~, ~, ~] = compute_obj_and_grads(brads, zk, 8, false, zk_width*10, 1e-1);
        % minimize -ah^2+bh+c.
        coef_a = -(fval+bval-2*val)/(h_fdd^2);
        coef_b = (fval-bval)/(2*h_fdd);
        if coef_a>0&&coef_b>0
            stepsize = coef_b/(2*coef_a);
        else
            stepsize = fallback_step_size;
        end

        rads_change = stepsize * search_direction;
        rads = rads + rads_change;

        iter = it;
        time = toc(tstart); 

        save(fullfile(savedir, sprintf('%d.mat', it)), ...
            'rads', 'val', 'zk', 'iter', 'time','stepsize','dvals','dzks', 'n', 'ncheb', 'ycenter', 'maxiter', 'stepsize', 'zk0', 'savedir', 'resume');

        fprintf('itv4 %3d | val: %.8f | zk: %.8f | ||dvals||: %.8f | time: %.2fs| step: %.4f\n', ...
                it, val, zk, norm(dvals), time, stepsize);
            
        prev_zk = zk + dot(dzks, rads_change);
        prev_dvals = dvals;
        cheb_factor = 0.05;

    end
end

function [rads, zk, hinv] = init_run(n, ycenter, zk0)
    rads   = initialize_circle(n, ycenter);
    zk     = zk0;
    hinv   = eye(n);
end
