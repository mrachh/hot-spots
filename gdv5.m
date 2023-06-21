function result = gdv5(dump_dir, n,bottom,a,b,h,min_step_size,max_iter)
    % stochastic coordinate descent
    if ~isfolder(dump_dir)
        mkdir(dump_dir);
    end
    [vertices, angles, rads] = initialize_polygon_vertices(n,bottom,a,b);
    loss_params = struct(...
    'default_chebabs',      [1 10], ...
    'udnorm_ord',              'inf', ...
    'unorm_ord',                  '2' ...
    );
    [loss, chebabs, zk] = compute_loss(vertices, loss_params, [1 10]);
    min_step_size_reached = false;
    max_iter_reached = false;
    not_converged = true;
    iter_idx = 0;
    descent_indices = randi([1 n],1,max_iter);
    while not_converged
        iter_idx = iter_idx + 1;
        iter_idx
        [f_zero, chebabs, zk] = compute_loss(vertices, loss_params, chebabs);
        rad_index = descent_indices(iter_idx);
        rad_index
        h_vector = zeros(1,n);
        h_vector(rad_index) = h;
        f_plus = compute_loss(compute_polygon_vertices(angles, rads+h_vector),loss_params,chebabs);
        f_minus = compute_loss(compute_polygon_vertices(angles, rads-h_vector),loss_params,chebabs);
        grad = zeros(1,n);
        grad(rad_index) = (f_plus - f_minus)/(2*h);
        step = 0.5*h*(f_plus-f_minus)/(f_plus+f_minus-2*f_zero);
        if step < 0
            step = 1.0;
        end
        % shrink step size until the shape has positive radius and is convex
        nice_shape = false;
        step = step*2;
        while ~nice_shape
            step = step/2;
            vertices = compute_polygon_vertices(angles, rads-step*grad);
            is_convex = length(convhull(vertices'))==(n+1);
            positive_radius = sum(rads>0)==n;
            nice_shape = is_convex&positive_radius;
        end
        not_improving = true;
        while not_improving
            f_next = compute_loss(compute_polygon_vertices(angles, rads-step*grad),loss_params,chebabs);
            if f_next < f_zero
                not_improving = false;
            end
            step = step/2;
        end
        if iter_idx > max_iter
            not_converged = false;
            max_iter_reached = true;
        end
        step = step*2;
        % optimization step
        rads = rads - step*grad;
        % normalize
        rads = rads/mean(rads);
        save(fullfile(dump_dir, [num2str(iter_idx), '.mat']));
    end