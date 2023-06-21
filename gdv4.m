function result = gdv4(dump_dir, n,bottom,a,b,h,min_step_size,max_iter)
    % vanilla gradient descent with no convexification
    result = 1;
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
    while not_converged
        iter_idx = iter_idx + 1;
        iter_idx
        [f_zero, chebabs, zk] = compute_loss(vertices, loss_params, chebabs);
        grad = zeros(1,n);
        for rad_index = 1:n 
            h_vector = zeros(1,n);
            h_vector(rad_index) = h;
            f_plus = compute_loss(compute_polygon_vertices(angles, rads+h_vector),loss_params,chebabs);
            f_minus = compute_loss(compute_polygon_vertices(angles, rads-h_vector),loss_params,chebabs);
            grad(rad_index) = (f_plus - f_minus)/(2*h);
        end
        f_plus = compute_loss(compute_polygon_vertices(angles, rads+h*grad),loss_params,chebabs);
        f_minus = compute_loss(compute_polygon_vertices(angles, rads-h*grad),loss_params,chebabs);
        % newton on gradient direction to find step size
        step = 0.5*h*(f_plus-f_minus)/(f_plus+f_minus-2*f_zero);
        if step < 0
            step = 1.0;
        end
        % shrink step size until the shape has positive radius
        nice_shape = false;
        step = step*2;
        while ~nice_shape
            step = step/2;
            vertices = compute_polygon_vertices(angles, rads-step*grad);
            positive_radius = sum(rads>0)==n;
            nice_shape = positive_radius;
        end
        not_improving = true;
        while not_improving
            f_next = compute_loss(compute_polygon_vertices(angles, rads-step*grad),loss_params,chebabs);
            if f_next < f_zero
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
        step = step*2;
        % optimization step
        rads = rads - step*grad;
        % normalize
        rads = rads/mean(rads);
        save(fullfile(dump_dir, [num2str(iter_idx), '.mat']));
    end
end
