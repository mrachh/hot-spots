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
        direction = zeros(num_params, 1);
        direction(i) = hspace;

        % Change this if # of params gets big
        left = fun(xval - direction);
        right = fun(xval + direction);
        grad(i) = (right - left) / (2 * hspace)
    end
end