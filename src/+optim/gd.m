function [opt, log] = gd(fun, init, cparams)
    %todo: doc

    % %read gradient descent parameters
    % maxiter = cparams.maxiter
    % eps = cparams.eps

    opt_dim = size(init)

    log = 0
    opt = fun(init)

end