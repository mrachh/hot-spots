function [opt, log] = gd(fun, init, cparams)
    %todo: doc
    %convergence criteria: grad 2-norm < cparams.eps

    %read gradient descent parameters
    maxiter = cparams.maxiter;
    eps = cparams.eps;
    hspace = cparams.hspace;
    line_search_eps = cparams.line_search_eps;
    line_search_beta = cparams.line_search_beta;
    opt = init;
    
    loss_arr = nan(maxiter);
    step_arr = nan(maxiter);
    grad_arr = nan(maxiter);
    weight_arr = nan(maxiter, length(init));
    gradient_descent_converged = false;

    for i = 1:maxiter
        if gradient_descent_converged
            fprintf('gradient descent converged after %d steps\n', ...
            i);
            break;
        end

        grad = optim.gd_grad(fun, opt, hspace);
        grad_norm = norm(grad);
        loss = fun(opt);
        gradient_descent_converged = (grad_norm < eps);

        %line search
        line_search_converged = false;
        step = grad_norm;
            while not(line_search_converged)
                right = fun(opt + step * grad);
                left = fun(opt - step * grad);
                is_linear = (abs(right - 2*loss + left) < line_search_eps);

                %compute quadratic fitting
                if is_linear
                    break;
                else
                    better_step = (step/2)*...
                        (right - left)/(right - 2*loss + left);
                end
                
                better_loss = fun(opt - grad * better_step);

                % if better_loss is actually higher, 
                %   we shrink it until it's too small.
                if min(left, better_loss) < loss
                    line_search_converged = true;
                    if better_loss < left
                        step = better_step;
                    end
                elseif step < line_search_eps
                    line_search_converged = true;
                else
                    step = step * line_search_beta;
                end
            end
        
            %update weight
            opt = opt - step * grad;

        %record
        loss_arr(i) = loss;
        step_arr(i) = step;
        grad_arr(i) = grad_norm;
        weight_arr(i,:) = opt;
    end

    if not(gradient_descent_converged)
        fprintf('gradient descent not converged after %d steps\n', ...
            maxiter);
    end
    
    log = struct( ...
            'loss',   loss_arr, ...
            'step',   step_arr, ...
            'grad',   grad_arr, ...
            'weight', weight_arr);
end



% %function that computes gradient
% function grad = gd_grad(fun, xval, hspace)
%     %evaluates gradient using finite difference
%     num_params = length(xval);
%     grad = zeros(num_params);
%     for i = 1:num_params
%         xval(i) = xval(i) + hspace;
%         disp(xval)
%         fun_val_forward = fun(xval);
%         xval(i) = xval(i) - 2*hspace;
%         fun_val_backward = fun(xval);
%         grad(i) = (fun_val_forward + fun_val_backward)/(2*hspace);
%     end
% end