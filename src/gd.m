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

    %read gradient descent parameters
    maxiter = gd_params.maxiter;
    report = gd_params.report;
    eps = gd_params.eps;
    hspace = gd_params.hspace;
    line_search_eps = gd_params.line_search_eps;
    line_search_beta = gd_params.line_search_beta;
    savefn = gd_params.savefn;
    vert_type = loss_params.vert_type;
    opt = init;
    num_params = length(opt);
    valid_params = ones(1, num_params);
    num_valid_params = sum(valid_params);
    

    gd_log = struct();
    gd_log.loss = nan(maxiter + 1,1);
    gd_log.step = nan(maxiter + 1,1);
    gd_log.gradnorm = nan(maxiter + 1,1);
    gd_log.fdd = nan(maxiter + 1,1);
    gd_log.time = nan(maxiter + 1,1);
    gd_log.weight = nan(maxiter + 1, length(init));
    gd_log.valid_params = nan(maxiter + 1, length(init));
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
        if epoch == 1
            [loss, chebabs] = fun(opt, loss_params, nan, valid_params);
        else
            % Guess an interval using previous zk
            [loss, chebabs] = fun(opt, loss_params, chebabs, valid_params);
        end

        % Computes gradient
        grad = zeros(1, num_params);

        fprintf('Computing %d derivatives: \n', num_params);

        for param_idx = 1:num_params
            if valid_params(param_idx)
                fprintf('Compuing dx%d...\n', param_idx);
                direction = zeros(1, num_params);
                direction(param_idx) = hspace;

                % Change this if # of params gets big
                left = fun(opt - direction, loss_params, chebabs, valid_params);
                right = fun(opt + direction, loss_params, chebabs, valid_params);

                grad(param_idx) = (right - left) / (2 * hspace);
            else
                grad(param_idx) = 0;
            end
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

        right = fun(opt + hspace * grad_direction, loss_params, chebabs, valid_params);
        left = fun(opt - hspace * grad_direction, loss_params, chebabs, valid_params);

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

        % delete vertex if necessary
        for i = 1:num_params
            if valid_params(i)
                direction = zeros(1, num_params);
                direction(i) = grad(i) * line_search_eps;
                if ~ check_convex(opt - direction, vert_type, valid_params)
                    % delete this vertex
                    valid_params(i) = 0;
                    fprintf('vertex %d deleted \n', i);
                end
            end
        end

        % shrink step so that the shape is convex
        isconvex = check_convex(opt - step * grad, vert_type, valid_params);
        while ~isconvex
            step = step * line_search_beta;
            isconvex = check_convex(opt - step * grad, vert_type, valid_params);
            if step < line_search_eps
                gradient_descent_converged = true;
                fprintf('Failed to be convex')
                break;
            end
        end

        [better_loss, chebabs] = fun(opt - step * grad, loss_params, chebabs, valid_params);
        line_search_converged = (better_loss < loss);

        % Line search loop        

        while not(line_search_converged)

            % Shrink step size

            step = step * line_search_beta;
            [better_loss, chebabs] = fun(opt - step * grad, loss_params, chebabs, valid_params);
            line_search_converged = (better_loss < loss);

            % Raise error when step is too small
            if step < line_search_eps
                gradient_descent_converged = true;
                fprintf('Line search did not converge')
                break;
            end
        end
        
        % End of line search loop


        % Record
        gd_log.loss(epoch) = loss;
        gd_log.step(epoch) = step;
        gd_log.gradnorm(epoch) = grad_norm;
        gd_log.fdd(epoch) = fdd;
        gd_log.time(epoch) = toc(start);
        gd_log.weight(epoch,:) = opt;
        gd_log.valid_params(epoch,:) = valid_params;
        gd_log.grad(epoch,:) = grad;

        % Update weight
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



    gd_log = struct( ...
            'loss',                 gd_log.loss(1:num_steps), ...
            'step',                 gd_log.step(1:num_steps), ...
            'grad_norm',            gd_log.gradnorm(1:num_steps), ...
            'weight',               gd_log.weight(1:num_steps, 1:end), ...
            'valid_params',         gd_log.valid_params(1:num_steps, 1:end), ...
            'fdd',                  gd_log.fdd(1:num_steps), ...
            'time',                 gd_log.time(1:num_steps), ...
            'grad',                 gd_log.grad(1:num_steps, 1:end)...
            );

    if not(gradient_descent_converged & line_search_converged)
        fprintf('gradient descent did not converge after %d steps\n', ...
            epoch);
    else
        fprintf('gradient descent converged after %d steps\n', ...
            num_steps);
    end

    
end
