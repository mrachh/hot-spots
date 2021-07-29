function grad = gd_grad(fun, xval, hspace)
    % Evaluates gradient using centered difference
    % INPUT:
    %     fun: funtion handle for objective "f"
    %     xval: value of "x"
    %     hspace: step size
    % OUTPUT:
    %     grad: an estimate of gradient "f'(x)"
    
    num_params = length(xval);
    grad = zeros(1,num_params);
    for i = 1:num_params
        xval(i) = xval(i) + hspace;
        fun_val_forward = fun(xval);
        xval(i) = xval(i) - 2*hspace;
        fun_val_backward = fun(xval);
        grad(i) = (fun_val_forward - fun_val_backward)/(2*hspace);
    end
end