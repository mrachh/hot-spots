function gd_circlev9(n, ncheb, ycenter, maxiter, stepsize, zk0, savedir, resume, grad_thresh, max_vertices, use_cluster_startup, init_mode, h_fdd)
    clearvars -except n ncheb ycenter maxiter stepsize zk0 savedir resume grad_thresh max_vertices use_cluster_startup init_mode h_fdd;
    clc;

    if nargin < 9 || isempty(grad_thresh)
        grad_thresh = 1e-6;
    end
    if nargin < 12 || isempty(init_mode)
        init_mode = "circle";
    end
    if nargin < 13 || isempty(h_fdd)
        h_fdd = 1e-4;
    end
    if nargin < 10 || isempty(max_vertices)
        max_vertices = 128;
    end
    if nargin < 11 || isempty(use_cluster_startup)
        use_cluster_startup = true;
    end

    % % tmp hack
    % if grad_thresh > 3e-6 && grad_thresh < 7e-6
    %     grad_thresh = 1e-10;
    % else
    %     return;  % exit this function/script
    % end


    addpath ../src
    addpath ../src_shaper_ders/
    if use_cluster_startup
        cluster_startup;
    else
        local_startup;
    end

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
            if isfield(S, 'angles')
                angles = S.angles;
            else
                angles = initialize_angles(length(rads));
            end
            if isfield(S, 'init_mode')
                init_mode = string(S.init_mode);
            end
            start_iter = S.iter + 1;
        else
            [rads, angles, prev_zk] = init_run(n, ycenter, zk0, init_mode);
            start_iter = 1;
        end
    else
        delete(fullfile(savedir, '*.mat'));
        [rads, angles, prev_zk] = init_run(n, ycenter, zk0, init_mode);
        start_iter = 1;
    end

    cheb_factor = 0.5;
    cheb_factor_fallback = 0.5;

    for it = start_iter:maxiter
        tstart = tic;
        [val, dvals, zk, dzks] = compute_obj_and_grads(rads, prev_zk, ncheb, true, cheb_factor, cheb_factor_fallback, [], angles);
        grad_norm = norm(dvals);
        has_enough_vertices = length(rads) >= max_vertices;

        added_vertex = false;
        insertion_meta = struct();
        converged = false;
        if grad_norm < grad_thresh
            if ~has_enough_vertices
                [candidate_rads, candidate_angles, insertion_meta] = insert_all_midpoints(rads, angles, max_vertices);
                if insertion_meta.added_count > 0
                    rads = candidate_rads;
                    angles = candidate_angles;
                    added_vertex = true;
                end
            else
                converged = true;
            end
        end

        if converged
            iter = it;
            time = toc(tstart);
            save(fullfile(savedir, sprintf('%d.mat', it)), ...
                'rads', 'angles', 'val', 'zk', 'iter', 'time','stepsize','dvals','dzks', ...
                'grad_norm', 'added_vertex', 'max_vertices', 'grad_thresh', 'use_cluster_startup', 'init_mode', 'converged');

            fprintf('itv9 %3d | val: %.8f | zk: %.8f | ||dvals||: %.8f | time: %.2fs | converged at n = %d\n', ...
                    it, val, zk, grad_norm, time, length(rads));
            break;
        end

        if added_vertex
            iter = it;
            time = toc(tstart);
            save(fullfile(savedir, sprintf('%d.mat', it)), ...
                'rads', 'angles', 'val', 'zk', 'iter', 'time','stepsize','dvals','dzks', ...
                'grad_norm', 'added_vertex', 'insertion_meta', 'max_vertices', 'grad_thresh', 'use_cluster_startup', 'init_mode');

            fprintf('itv9 %3d | val: %.8f | zk: %.8f | ||dvals||: %.8f | time: %.2fs | inserted %d vertices -> n = %d\n', ...
                    it, val, zk, grad_norm, time, insertion_meta.added_count, length(rads));

            prev_zk = zk;
            cheb_factor = 0.5;
            cheb_factor_fallback = 0.5;
            continue;
        end

        if grad_norm > 0
            dvals_direction = dvals./grad_norm;
        else
            dvals_direction = zeros(size(dvals));
        end

        frads = rads + h_fdd.*dvals_direction;
        brads = rads - h_fdd.*dvals_direction;
        [fval, ~, ~, ~] = compute_obj_and_grads(frads, zk, ncheb, false, 1e-3, 1e-1, [], angles);
        [bval, ~, ~, ~] = compute_obj_and_grads(brads, zk, ncheb, false, 1e-3, 1e-1, [], angles);
        % minimize -ah^2+bh+c.
        coef_a = -(fval+bval-2*val)/(h_fdd^2);
        coef_b = (fval-bval)/(2*h_fdd);
        if coef_a>0&&coef_b>0
            stepsize = coef_b/(2*coef_a);
        else
            stepsize = grad_norm;
        end

        rads_change = stepsize * dvals_direction;
        rads = rads + rads_change;

        iter = it;
        time = toc(tstart); 

        save(fullfile(savedir, sprintf('%d.mat', it)), ...
            'rads', 'angles', 'val', 'zk', 'iter', 'time','stepsize','dvals','dzks', ...
            'grad_norm', 'added_vertex', 'max_vertices', 'grad_thresh', 'use_cluster_startup', 'init_mode');

        fprintf('itv9 %3d | val: %.8f | zk: %.8f | ||dvals||: %.8f | time: %.2fs | a: %.4f | step: %.4f | n = %d\n', ...
                it, val, zk, grad_norm, time, coef_a, stepsize, length(rads));
            
        prev_zk = zk + dot(dzks, rads_change);
        cheb_factor = 0.05;
    end
end

function [rads, angles, insertion_meta] = insert_all_midpoints(rads, angles, max_vertices)
    n = length(rads);
    insertion_meta = struct('added_count', 0, ...
                            'insert_position', [], ...
                            'left_idx', [], ...
                            'right_idx', [], ...
                            'angle', [], ...
                            'radius', []);
    if n >= max_vertices
        return;
    end
    num_edges = n - 1;
    if num_edges <= 0
        return;
    end
    verts = compute_polygon_vertices(angles, rads);
    total_new = num_edges;
    new_len = n + total_new;
    new_rads = zeros(1, new_len);
    new_angles = zeros(1, new_len);
    inserted_positions = zeros(1, total_new);
    inserted_angles = zeros(1, total_new);
    inserted_radii = zeros(1, total_new);
    inserted_left = zeros(1, total_new);
    inserted_right = zeros(1, total_new);

    idx = 1;
    insert_idx = 0;
    for k = 1:n
        new_rads(idx) = rads(k);
        new_angles(idx) = angles(k);
        idx = idx + 1;

        if k < n
            insert_idx = insert_idx + 1;
            angle_new = 0.5 * (angles(k) + angles(k+1));
            midpoint = 0.5 * (verts(:, k) + verts(:, k+1));
            direction = [cos(angle_new); sin(angle_new)];
            new_radius = dot(midpoint, direction);
            if ~isfinite(new_radius) || new_radius <= 0
                new_radius = max(norm(midpoint), eps);
            end

            new_rads(idx) = new_radius;
            new_angles(idx) = angle_new;
            inserted_positions(insert_idx) = idx;
            inserted_angles(insert_idx) = angle_new;
            inserted_radii(insert_idx) = new_radius;
            inserted_left(insert_idx) = k;
            inserted_right(insert_idx) = k + 1;
            idx = idx + 1;
        end
    end

    rads = new_rads;
    angles = new_angles;
    insertion_meta = struct('added_count', insert_idx, ...
                            'insert_position', inserted_positions, ...
                            'left_idx', inserted_left, ...
                            'right_idx', inserted_right, ...
                            'angle', inserted_angles, ...
                            'radius', inserted_radii);
end

function [rads, angles, zk] = init_run(n, ycenter, zk0, init_mode)
    init_mode = string(init_mode);
    if init_mode == "semicircle"
        rads = ones(1, n);
        angles = initialize_angles(n);
    else
        [rads, angles] = initialize_circle(n, ycenter);
    end
    zk = zk0;
end
