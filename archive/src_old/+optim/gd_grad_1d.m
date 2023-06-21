function [grad, fdd, loss] = gd_grad_1d(fun, xval, hspace)
    % Evaluates gradient using centered difference
    % INPUT:
    %     fun: funtion handle for objective "f"
    %     xval: value of "x"
    %     hspace: step size
    % OUTPUT:
    %     grad: an estimate of gradient "f'(x)"
    %     fdd: f''(x)
    %     loss: f(x)
    
    left = fun(xval - hspace);
    right = fun(xval + hspace);
    center = fun(xval);

    grad = (right  - left) / (2 * hspace);
    loss = center;
    fdd = (right + left - 2 * center) / (hspace ^ 2);


end