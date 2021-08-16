function loss = rect_true_loss(weight, loss_params)

    % Computes true loss for integer p, q

    q = loss_params.u_q;
    p = loss_params.gradu_p;
    a = weight;
    beta = 0.5 - 1/(2*p) + 1/q;

    const = (2^(1/p) * pi^(1/p-2/q) * psi(p))/(psi(q)^2);
    loss = const * (a^(-p)+a)^(1/p)/( (a^(-2)+1)^beta * a^(1/q) );

end


function res = psi(r)
    res = gamma(r+1.0)^(1.0/r)/(2*gamma(1+r/2.0)^(2.0/r));
end
