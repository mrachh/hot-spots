function [opt, log] = gd(fun, init, cparams)
    %todo: 
    %convergence criteria: grad 2-norm < cparams.eps

    %read gradient descent parameters
    maxiter = cparams.maxiter
    eps = cparams.eps
    hspace = cparams.hspace
    line_search_eps = cparams.line_search_eps
    opt = init
    
    loss_arr = nan(maxiter)
    step_arr = nan(maxiter)
    grad_arr = nan(maxiter)
    weight_arr = nan(maxiter, length(init))
    gradient_descent_converged = false

    for i = 1:maxiter
        if gradient_descent_converged:
            break
        end

        grad = gd_grad(@fun, opt, hspace)
        grad_norm = norm(grad)
        loss = fun(opt)
        gradient_descent_converged = (grad_norm < eps)

        %line search
        line_search_converged = false
        step = grad_norm
            while not(line_search_converged)
                right = fun(opt + grad)
                left = fun(opt - grad)
                is_linear = (right - 2*loss + left > line_search_eps)
                if is_linear
                    break
                else
                    body
                end
            end


        %record
        loss_arr(i) = loss
        step_arr(i) = step
        grad_arr(i) = grad_norm
        weight_arr(i,:) = opt
    end

    if not(gradient_descent_converged)
        fprintf('gradient descent not converged after %d steps', ...
            maxiter)
    end
    
    log = { 'loss',   loss_arr,
            'step',   step_arr,
            'grad',   grad_arr,
            'weight', weight_arr}
end