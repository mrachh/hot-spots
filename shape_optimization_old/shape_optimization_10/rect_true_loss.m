function loss = rect_true_loss(weight, loss_params)

    % Computes true loss for integer p, q


    q = str2double(loss_params.unorm_ord);
    p = str2double(loss_params.udnorm_ord);
    a = weight;
    beta = 0.5 - 1/(2*p) + 1/q;

    const = (2^(1/p) * pi^(1/p-2/q) * psi(p))/(psi(q)^2);
    loss = - const * (a^(-p)+a)^(1/p)/( (a^(-2)+1)^beta * a^(1/q) );

end


function res = psi(r)
    res = gamma(r+1)^(1/r)/(2*gamma(1+r/2)^(2/r));
end
