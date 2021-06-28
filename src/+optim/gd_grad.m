function grad = gd_grad(fun, xval, h)
    %evaluates gradient using finite difference
    num_params = length(xval)
    fun_val_center = fun(xval)
    for i = 1:num_params
        xval(i) = xval(i) + h
        fun_val_forward = 
    end
end