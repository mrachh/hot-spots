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

    cheb_left = 0.95;
    cheb_right = 1.05;
    %read gradient descent parameters
    maxiter = cparams.maxiter;
    report = cparams.report;
    eps = cparams.eps;
    hspace = cparams.hspace;
    line_search_eps = cparams.line_search_eps;
    line_search_beta = cparams.line_search_beta;
    opt = init;

    gd_log = struct();
    gd_log.loss = nan(maxiter,1);
    gd_log.step = nan(maxiter,1);
    gd_log.gradnorm = nan(maxiter,1);
    gd_log.fdd = nan(maxiter,1);
    gd_log.time = nan(maxiter,1);
    gd_log.maxgradloc = nan(maxiter,1);
    gd_log.weight = nan(maxiter, length(init));
    gd_log.grad = nan(maxiter, length(init));
    gradient_descent_converged = false;
    line_search_converged = false;
    zk = nan;

    for epoch = 1:maxiter

        if gradient_descent_converged
            num_steps = epoch;
            break;
        end

        % Time a single iteration
        start = tic;

        % Evaluate loss at optimal value
        if isnan(zk)
            [loss, zk, max_grad_loc] = fun(opt);
        else
            % Guess an interval using previous zk
            chebab = [zk*cheb_left, zk*cheb_right];
            try
                [loss, zk, max_grad_loc] = fun(opt, chebab);
            catch
                [loss, zk] = fun(opt);
            end
        end

        % Guess an interval using previous zk
        chebab = [zk*cheb_left, zk*cheb_right];

        % Computes gradient
        num_params = length(opt);
        grad = zeros(1, num_params);

        fprintf('Computing %d derivatives: \n', num_params);
        for param_idx = 1:num_params
            fprintf('Compuing dx%d...\n', param_idx);
            direction = zeros(1, num_params);
            direction(param_idx) = hspace;

            % Change this if # of params gets big
            try
                left = fun(opt - direction, chebab);
            catch
                left = fun(opt - direction);
            end

            try
                right = fun(opt + direction, chebab);
            catch
                right = fun(opt + direction);
            end

            grad(param_idx) = (right - left) / (2 * hspace);
        end
        fprintf('Gradient computed!\n')

        % End of gradient computation
        
        grad_norm = norm(grad);
        grad_direction = grad / grad_norm;
        gradient_descent_converged = (grad_norm < eps);

        if gradient_descent_converged
            num_steps = epoch;
            break;
        end

        % Line search

        % Initialize step size with second derivative "fdd"

        try
            right = fun(opt + hspace * grad_direction, chebab);
        catch
            right = fun(opt + hspace * grad_direction);
        end
        
        try
            left = fun(opt - hspace * grad_direction, chebab);
        catch
            left = fun(opt - hspace * grad_direction)
        end

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
        gd_log.loss(epoch) = loss;
        gd_log.step(epoch) = step;
        gd_log.gradnorm(epoch) = grad_norm;
        gd_log.fdd(epoch) = fdd;
        gd_log.time(epoch) = toc(start);
        gd_log.weight(epoch,:) = opt;
        gd_log.grad(epoch,:) = grad;
        gd_log.maxgradloc(epoch) = max_grad_loc;

        %dump log file
        fprintf('Saving log file...\n');
        save('gd_log.mat', '-struct', 'gd_log');

        if (mod(epoch, report) == 1) | (report == 1)
            fprintf('iter: %d, loss: %5.2e, grad: %5.2e, 2nd-deri: %5.2e, time: %5.2e\n', ...
                epoch, loss, grad_norm, fdd, gd_log.time(epoch));
            fprintf('Current weight %s\n', mat2str(opt));
            fprintf('Current gradient %s\n', mat2str(grad));

        end
    end

    % End of GD loop



    gd_log = struct( ...
            'loss',         gd_log.loss(1:num_steps), ...
            'step',         gd_log.step(1:num_steps), ...
            'grad_norm',    gd_log.gradnorm(1:num_steps), ...
            'weight',       gd_log.weight(1:num_steps, 1:end), ...
            'fdd',          gd_log.fdd(1:num_steps), ...
            'time',         gd_log.time(1:num_steps), ...
            'grad',         gd_log.grad(1:num_steps, 1:end), ...
            'max_grad_loc', gd_log.maxgradloc(1:num_steps) ...
            );

    if not(gradient_descent_converged & line_search_converged)
        fprintf('gradient descent did not converge after %d steps\n', ...
            epoch);
    else
        fprintf('gradient descent converged after %d steps\n', ...
            num_steps);
    end

    
end
