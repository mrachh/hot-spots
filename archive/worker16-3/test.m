clear;clc;addpath('../src');

diary('test.txt');

% Parameters
npoints = 256;
epsilon = 5e-3;

% Create two chunker objects
q = 2;
p = inf;
beta = 1/2 - 1/(2*p) + 1/(q);
rhos = ones(1,npoints);
phis = find_phis(npoints);
rs_plus = perturb_radii(rhos, phis, epsilon)
rs_minus = perturb_radii(rhos, phis, -epsilon)
chebabs = [3.5 4.5];
[chnkr_original, ~] = chnk_poly(rhos);
[chnkr_plus, center] = chnk_poly(rs_plus);
[chnkr_minus, center] = chnk_poly(rs_minus);

% % Plot
% clf;
% plot(chnkr_original);
% hold on
% plot(chnkr_plus);
% hold on
% plot(chnkr_minus);
% hold on
% axis equal
% legend('original','+\epsilon','-\epsilon')


% Compute Sigmas
tic
[zk_plus, err_nullvec, sigma_plus] = find_first_eig(chnkr_plus, chebabs);
toc
err_nullvec
tic
[zk_minus, err_nullvec, sigma_minus] = find_first_eig(chnkr_minus, chebabs);
err_nullvec
toc
save






% WIP
error('nothing')
[ud_p] = ud_norm(chnkr, zk, sigma, p)

error('nothign')

start = tic; u_q = u_norm(chnkr, zk, sigma, center, q)
fprintf('Time to compute 2-norm: %5.2e\n', toc(start));

loss =  - ud_p/(u_q * (zk^(2*beta)));


function res = find_phis(n)
    % return the angles given number of vertices
    res = [];
    for i = 1:n
        res(i) = pi * (i-1) / (n-1);
    end
end

function res = perturb_radii(rhos, phis, epsilon)
% r = (1+ epsilon * rho * v(phi)) * rho
    res = (1 + epsilon .* rhos .* v(phis)) .* rhos;
end

function res = v(phis)
    % Polynomial perturbation:
    % v(phi) = (phis-pi/2)^d
    res = cos(2 * phis)
end