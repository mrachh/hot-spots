clear;clc;addpath('../src');

diary('test.txt');

n = 128;
% rhos1 = ones(1, n);
% loss_params = struct(...
%     'default_chebabs',      [10 16], ...
%     'chnk_fun',             @chnk_poly, ...
%     'udnorm_ord',              'inf', ...
%     'unorm_ord',                '2' ...
% );
% res = loss(rhos1, loss_params)


rhos2 = ones(1, n);
loss_params = struct(...
    'default_chebabs',      [1 20], ...
    'chnk_fun',             @chnk_poly, ...
    'udnorm_ord',              'inf', ...
    'unorm_ord',                '2' ...
);
res = loss(rhos2, loss_params)



function res = find_phis(n)
    % return the angles given number of vertices
    res = [];
    for i = 1:n
        res(i) = pi * (i-1) / (n-1);
    end
end

function res = perturb_radii(rhos, phis, epsilon, d)
% r = (1+ epsilon * rho * v(phi)) * rho
    res = (1 + epsilon .* rhos .* v(phis, d)) .* rhos;
end

function res = v(phis, d)
    % Polynomial perturbation:
    % v(phi) = (phis-pi/2)^d
    res = (phis-pi/2).^d;
end