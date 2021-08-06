function [opt, gd_log] = gd(fun, init, cparams)
    %Performs gradient descent on one dimensional input
    % INPUT:
    %     fun: function handle for objective "f"
    %     init: initial value for weight "x"
    %     cparams (struct):
    %         maxiter: maximum iteration
    %         report: frequency of reporting loss
    %         eps: tolerance for gradient descent
    %         hspace: step size for gradient estimate
    %         line_search_eps: tolerance for line search
    %         line_search_beta: shrinking factor for gradient descent step size
    % OUTPUT:
    %     opt: optimal weight "x"
    %     gd_log (struct):
    %         loss: loss over iterations
    %         step: step sizes over iterations
    %         grad: gradient norms over iterations
    %         weight: weights "x" over iterations

    %read gradient descent parameters
    maxiter = cparams.maxiter;
    report = cparams.report;
    eps = cparams.eps;
    hspace = cparams.hspace;
    line_search_eps = cparams.line_search_eps;
    line_search_beta = cparams.line_search_beta;
    opt = init;

    loss_arr = nan(maxiter,1);
    step_arr = nan(maxiter,1);
    gradnorm_arr = nan(maxiter,1);
    fdd_arr = nan(maxiter,1);
    time_arr = nan(maxiter,1);
    weight_arr = nan(maxiter, length(init));
    grad_arr = nan(maxiter, length(init));
    gradient_descent_converged = false;

    for i = 1:maxiter

        if gradient_descent_converged
            fprintf('gradient descent converged after %d steps\n', ...
            i);
            num_steps = i;
            break;
        end

        % Time a single iteration
        start = tic;

        % Evaluate loss at optimal value
        loss = fun(opt);

        % Computes gradient
        num_params = length(xval);
        grad = zeros(1, num_params);

        fprintf('Computing %d derivatives: \n', num_params);
        for i = 1:num_params
            fprintf('Compuing dx%d...\n', i);
            direction = zeros(1, num_params);
            direction(i) = hspace;

            % Change this if # of params gets big
            left = fun(xval - direction);
            right = fun(xval + direction);
            grad(i) = (right - left) / (2 * hspace);
        end
        fprintf('Gradient computed!\n')

        % End of gradient computation
        
        grad_norm = norm(grad);
        grad_direction = grad / grad_norm;
        gradient_descent_converged = (grad_norm < eps);

        % Line search

        % Initialize step size with second derivative (stored as fdd)

        right = fun(opt + hspace * grad_direction);
        left = fun(opt - hspace * grad_direction);
        center = loss;
        fdd = (right - 2*center + left) / (hspace^2);
 
        % Check second derivative

        if fdd < 0
            warning('Negative second derivative %5.2e', fdd);
            % step = grad_norm;
            step = 1;
        elseif fdd == 0
            % step = grad_norm;
            step = 1;
        else
            step = 1.0 / fdd;
        end


        better_loss = fun(opt - step * grad);
        line_search_converged = (better_loss < loss);

        % Line search loop        

        while not(line_search_converged)

            % Shrink step size

            step = step * line_search_beta;
            better_loss = fun(opt - step * grad);
            line_search_converged = (better_loss < loss);

            % Raise error when step is too small
            if step < line_search_eps
                gradient_descent_converged = true;
                fprintf('Line search did not converge')
                break;
            end
        end
        
        % End of line search loop

        % Update weight
        opt = opt - step * grad;

        % Record
        loss_arr(i) = loss;
        step_arr(i) = step;
        gradnorm_arr(i) = grad_norm;
        fdd_arr(i) = fdd;
        time_arr(i) = toc(start);
        weight_arr(i,:) = opt;
        grad_arr(i,:) = grad;
        if (mod(i, report) == 1) | (report == 1)
            fprintf('iter: %d, loss: %5.2e, grad: %5.2e, 2nd-deri: %5.2e, time: %5.2e\n', ...
                i, loss, grad_norm, fdd, time_arr(i));
            fprintf('Current weight %s\n', mat2str(opt));

        end
    end

    % End of GD loop

    if not(gradient_descent_converged & line_search_converged)
        fprintf('gradient descent did not converge after %d steps\n', ...
            maxiter);
    end
    
    gd_log = struct( ...
            'loss',         loss_arr(1:num_steps), ...
            'step',         step_arr(1:num_steps), ...
            'grad_norm',    gradnorm_arr(1:num_steps), ...
            'weight',       weight_arr(1:num_steps, 1:end), ...
            'fdd',          fdd_arr(1:num_steps), ...
            'time',         time_arr(1:num_steps), ...
            'grad',         grad_arr(1:num_steps, 1:end) ...
            );
end
