function result = gd(dump_dir, h,min_step_size,max_iter,init_angles,init_rads, maxchunklen, mean_rads)
    % compute ud at origin + asymmetric polygon
    % normalize average of rads to mean_rads at the end of each iter
    n = length(init_angles);
    result = 1;
    conv_eps = 0;
    if ~isfolder(dump_dir)
        mkdir(dump_dir);
    end
    angles = init_angles;
    rads = init_rads;
    rads = mean_rads*rads/mean(rads);
    vertices = compute_polygon_vertices(angles, rads);
    loss_params = struct(...
    'default_chebabs',      [1 10], ...
    'udnorm_ord',              'inf', ...
    'unorm_ord',                  '2' ...
    );
    [loss, chebabs, zk] = compute_loss(vertices, loss_params, [1 10], maxchunklen);
    min_step_size_reached = false;
    max_iter_reached = false;
    not_converged = true;
    iter_idx = 0;
    while not_converged
        iter_idx = iter_idx + 1;
        curr_rads = rads;
        iter_idx
        rads
        [f_zero, chebabs, zk] = compute_loss(compute_polygon_vertices(angles, rads), loss_params, chebabs,maxchunklen);
        f_zero
        grad = zeros(1,n);
        for rad_index = 1:n
            rad_index
            h_vector = zeros(1,n);
            h_vector(rad_index) = h;
            f_plus = compute_loss(compute_polygon_vertices(angles, rads+h_vector),loss_params,chebabs,maxchunklen);
            f_minus = compute_loss(compute_polygon_vertices(angles, rads-h_vector),loss_params,chebabs,maxchunklen);
            grad(rad_index) = (f_plus - f_minus)/(2*h);
        end
        f_plus = compute_loss(compute_polygon_vertices(angles, rads+h*grad),loss_params,chebabs,maxchunklen);
        f_minus = compute_loss(compute_polygon_vertices(angles, rads-h*grad),loss_params,chebabs,maxchunklen);
        step = 0.5*h*(f_plus-f_minus)/(f_plus+f_minus-2*f_zero);
        if step < 0
            step = 1.0;
        end
        % shrink step size until the shape 1. is convex, 2. has positive radius
        nice_shape = false;
        step = step*2;
        positive_radius = false;
        step = step*2;
        while ~positive_radius
            step = step/2;
            positive_radius = sum(rads-step*grad>0)==n;
        end
        not_improving = true;
        while not_improving
            rads_next = rads-step*grad;
            f_next = compute_loss(compute_polygon_vertices(angles, rads_next),loss_params,chebabs,maxchunklen);
            improvement = f_zero - f_next;
            step
            improvement
            if improvement > 0
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