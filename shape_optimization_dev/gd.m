function [opt, gd_log] = gd(fun, init, gd_params, loss_params)
    %Performs gradient descent on one dimensional input
    % INPUT:
    %     fun: function handle for objective "f"
    %     init: initial value for weight "x"
    %     gd_params (struct):
    %         maxiter: maximum iteration
    %         report: frequency of reporting loss
    %         eps: tolerance for gradient descent
    %         hspace: step size for gradient estimate
    %         line_search_eps: tolerance for line search
    %         line_search_beta: shrinking factor for gradient descent step size
    %     loss_params (struct):
    %         default_chebabs:          [1 10]
    %         chnk_fun:                 @chnk_polyeven
    %         udnorm_ord:               '3'
    %         unorm_ord:                '2'
    % OUTPUT:
    %     opt: optimal weight "x"
    %     gd_log (struct):
    %         loss: loss over iterations
    %         step: step sizes over iterations
    %         grad: gradient norms over iterations
    %         weight: weights "x" over iterations

    % Read gradient descent parameters
    maxiter = gd_params.maxiter;
    report = gd_params.report;
    eps = gd_params.eps;
    hspace = gd_params.hspace;
    line_search_eps = gd_params.line_search_eps;
    line_search_beta = gd_params.line_search_beta;
    savefn = gd_params.savefn;
    opt = init;

    % Initialize log file
    gd_log = struct();
    gd_log.loss = nan(maxiter + 1,1);
    gd_log.step = nan(maxiter + 1,1);
    gd_log.gradnorm = nan(maxiter + 1,1);
    gd_log.fdd = nan(maxiter + 1,1);
    gd_log.time = nan(maxiter + 1,1);
    gd_log.weight = nan(maxiter + 1, length(init));
    gd_log.grad = nan(maxiter + 1, length(init));
    gradient_descent_converged = false;
    line_search_converged = false;

    for epoch = 1:maxiter
        if gradient_descent_converged
            num_steps = epoch;
            break;
        end

        % Time a single iteration
        start = tic;

        % Evaluate loss at current optimal weight
        [loss, chebabs] = fun(opt, loss_params);
        loss
        % Computes gradient using finite difference
        num_params = length(opt);
        grad = zeros(1, num_params);
        fprintf('Computing %d derivatives: \n', num_params);
        for param_idx = 1:num_params
            fprintf('Compuing dx%d...\n', param_idx);
            direction = zeros(1, num_params);
            direction(param_idx) = hspace;
            left = fun(opt - direction, loss_params, chebabs);
            right = fun(opt + direction, loss_params, chebabs);
            grad(param_idx) = (right - left) / (2 * hspace);
        end
        fprintf('Gradient computed!\n')
        grad_norm = norm(grad);
        grad_direction = grad;
        gradient_descent_converged = (grad_norm < eps);
        if gradient_descent_converged
            num_steps = epoch;
            break;
        end
        % Line search
        % Initialize step size with second derivative "fdd"
        right = fun(opt + hspace * grad_direction, loss_params, chebabs);
        left = fun(opt - hspace * grad_direction, loss_params, chebabs);
        center = loss;
        fdd = (right - 2*center + left) / (hspace^2);
        % Check second derivative
        if fdd < 0
            warning('Negative second derivative %5.2e', fdd);
            step = 1;
        elseif fdd == 0
            step = 1;
        else
            step = 1.0 / fdd;
        end

        % Make sure radii are positive
        max_steps = opt./(grad);
        max_steps = max_steps(max_steps>0);
        [~, num_directions_inward] = size(max_steps)
        if num_directions_inward > 0
            max_step = min(max_steps) - line_search_eps;
            step = min(step, max_step);
        end

        [better_loss, chebabs] = fun(opt - step * grad, loss_params);
        line_search_converged = (better_loss < loss);

        % Line search loop        
        fprintf('Some statistics before line search: \n')
        step
        fdd
        grad
        opt

        
        line_search_iter = 0;
        while not(line_search_converged)
            line_search_iter = line_search_iter + 1;
            fprintf('Line search iter %d\n',line_search_iter);
            step = step * line_search_beta;
            [better_loss, chebabs] = fun(opt - step * grad, loss_params);
            line_search_converged = (better_loss < loss);
            % Raise error when step is too small
            if step < line_search_eps
                gradient_descent_converged = true;
                fprintf('Line search did not converge\n')
                break;
            end
        end
        % Record
        gd_log.loss(epoch) = loss;
        gd_log.step(epoch) = step;
        gd_log.gradnorm(epoch) = grad_norm;
        gd_log.fdd(epoch) = fdd;
        gd_log.time(epoch) = toc(start);
        gd_log.weight(epoch,:) = opt;
        gd_log.grad(epoch,:) = grad;

        % Update weight and valid indices
        opt = opt - step * grad;

        % Record next weight
        gd_log.weight(epoch+1,:) = opt;

        %dump log file
        fprintf('Saving log file...\n');
        save(savefn, '-struct', 'gd_log');

        if (mod(epoch, report) == 1) | (report == 1)
            fprintf('iter: %d, loss: %5.2e, grad: %5.2e, 2nd-deri: %5.2e, time: %5.2e\n', ...
                epoch, loss, grad_norm, fdd, gd_log.time(epoch));
            fprintf('Current weight %s\n', mat2str(opt));
            fprintf('Current gradient %s\n', mat2str(grad));
        end


    end

    % End of GD loop

    if not(gradient_descent_converged & line_search_converged)
        fprintf('gradient descent did not converge after %d steps\n', ...
            epoch);
    else
        fprintf('gradient descent converged after %d steps\n', ...
            num_steps);
    end

    
end
