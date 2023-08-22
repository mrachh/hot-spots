function result = gd(dump_dir, h,min_step_size,max_iter,init_angles,init_rads,init_chebabs, maxchunklen, mean_rads, quadratic_penalty_factor, step_size_lower_bound, workers)
    % compute ud at origin + asymmetric polygon
    % normalize average of rads to mean_rads at the end of each iter
    % min_step_size: stop if < min_step_size
    % step_size_lower_bound: bound step size by this number (disables the min_step_size feature)
    n = length(init_angles);
    result = 1;
    if ~isfolder(dump_dir)
        mkdir(dump_dir);
    end
    angles = init_angles;
    rads = init_rads;
    rads = mean_rads*rads/mean(rads);
    loss_params = struct(...
    'default_chebabs',      init_chebabs, ...
    'udnorm_ord',              'inf', ...
    'unorm_ord',                  '2' ...
    );
    [loss, chebabs, zk] = compute_loss_gd(angles, rads, loss_params, init_chebabs, maxchunklen,quadratic_penalty_factor);
    min_step_size_reached = false;
    max_iter_reached = false;
    not_converged = true;
    iter_idx = 0;
    while not_converged
        iter_idx = iter_idx + 1;
        [f_zero, chebabs, zk, ud_p, u_q, err_nullvec] = compute_loss_gd(angles, rads, loss_params, chebabs,maxchunklen,quadratic_penalty_factor);
        curr_rads = rads;
        curr_chebabs = chebabs;
        curr_zk = zk;
        curr_err_nullvec = err_nullvec;
        curr_objective = f_zero;

        iter_idx
        curr_objective

        grad = zeros(1,n);
        
        p = gcp;
        delete(p);
        parpool(workers);
        parfor (rad_index = 1:n,workers)
            rad_index
            h_vector = zeros(1,n);
            h_vector(rad_index) = h;
            f_plus = compute_loss_gd(angles, rads+h_vector,loss_params,chebabs,maxchunklen,quadratic_penalty_factor);
            f_minus = compute_loss_gd(angles, rads-h_vector,loss_params,chebabs,maxchunklen,quadratic_penalty_factor);
            grad(rad_index) = (f_plus - f_minus)/(2*h);
        end

        curr_grad = grad;
        grad_norm = sqrt(sum(grad.^2));
        grad_direction = grad/grad_norm;

        f_plus = compute_loss_gd(angles,rads+h*grad_direction,loss_params,chebabs,maxchunklen,quadratic_penalty_factor);
        f_minus = compute_loss_gd(angles,rads-h*grad_direction,loss_params,chebabs,maxchunklen,quadratic_penalty_factor);
        step = 0.5*h*(f_plus-f_minus)/(f_plus+f_minus-2*f_zero);

        if step < 0
            step = 1;
        end
        positive_radius = false;

        step = step*2;
        while ~positive_radius
            step = step/2;
            positive_radius = sum(rads-step*grad_direction>0)==n;
        end
        
        not_improving = true;
        
        % vertex deletion if not convex
        % skip line search if vertex deleted
        % binary search
        n = length(rads);
        convex_eps = 1e-10;
        left_step = 1e-7;
        right_step = step;
        inner_angles = compute_inner_angles(angles, rads-step*grad);
        not_converged = ~(sum(inner_angles-pi<convex_eps)==n);
        while not_converged
            mid_step = (left_step+right_step)/2;
            inner_angles = compute_inner_angles(angles, rads-mid_step*grad);
            mid_converged = (sum(inner_angles-pi<convex_eps)==n);
            if mid_converged
                left_step = mid_step;
            else
                right_step = mid_step;
            end
            if right_step - left_step < 1e-15
                not_converged = false;
            end
            [left_step, mid_step, right_step]
        end
        step = left_step;
        % compute active indices
        rads = rads - step*grad;
        inner_angles = compute_inner_angles(angles, rads);
        active_indices = abs(inner_angles-pi)>10*convex_eps;
        if sum(active_indices)~=n
            % vertex removal
            angles = angles(active_indices);
            rads_next = rads(active_indices);
            % skip line search
            not_improving = false;
        end

        while not_improving
            rads_next = rads-step*grad_direction;
            f_next = compute_loss_gd(angles,rads_next,loss_params,chebabs,maxchunklen,quadratic_penalty_factor);
            improvement = f_zero - f_next;
            step
            improvement
            if improvement > 0
                not_improving = false;
            end
            if step < step_size_lower_bound
                not_improving = false;
            end
            if step < min_step_size
                not_improving = false;
                min_step_size_reached = true;
                not_converged = false;
            end
            step = step/2;
        end

        if iter_idx > max_iter
            not_converged = false;
            max_iter_reached = true;
        end

        % optimization step
        rads = rads_next;
        % normalize
        rads = mean_rads*rads/mean(rads);
        save(fullfile(dump_dir, [num2str(iter_idx), '.mat']));
    end
end

function [loss, chebabs, zk, ud_p, u_q, err_nullvec] = compute_loss_gd(angles, rads, loss_params, chebabs, maxchunklen, quadratic_penalty_factor)
    verts = compute_polygon_vertices(angles, rads);
    [loss, chebabs, zk, ud_p, u_q, err_nullvec] = compute_loss(verts, loss_params, chebabs, maxchunklen);
    if quadratic_penalty_factor >0
        inner_angles = compute_inner_angles(rads);
        quadratic_penalty = sum((min(pi - inner_angles, 0)).^2);
        loss = loss+quadratic_penalty_factor*quadratic_penalty;
    end
end