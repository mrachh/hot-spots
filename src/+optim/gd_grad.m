function grad = gd_grad(fun, xval, hspace)
    %evaluates gradient using finite difference
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