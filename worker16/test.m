clear;clc;addpath('../src');

diary('test.txt');

npoints = [16 64 256];
epss = [0 5e-3 1e-3 5e-4 -5e-3 -1e-3 -5e-4];
ds = [2 3];

num_npoints = length(npoints);
num_epss = length(epss);
num_ds = length(ds);

loss_params = struct(...
    'default_chebabs',      [1 10], ...
    'chnk_fun',             @chnk_poly, ...
    'udnorm_ord',              'inf', ...
    'unorm_ord',                '2' ...
);

res_npoint = [];
res_eps = [];
res_d = [];
res_loss = [];

idx = 1;
for d_idx = 1:num_ds
    for eps_idx = 1:num_epss
        for npoint_idx = 1:num_npoints
            % load setting
            d = ds(d_idx);
            epsilon = epss(eps_idx);
            npoint = npoints(npoint_idx);

            % compute
            phis = find_phis(npoint);
            rhos = ones(1, npoint);
            rs = perturb_radii(rhos, phis, epsilon, d);
            res = loss(rs, loss_params);

            % record
            save;
            res_npoint(idx) = npoint;
            res_eps(idx) = epsilon;
            res_d(idx) = d;
            res_loss(idx) = res;

            % update
            idx = idx + 1;

            % print
            idx
            d
            epsilon
            npoint
            res
        end
    end
end


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