addpath('../src');
clear;

chnkr = rect_chnk(2.0, true);

[zk, err_nullvec, sigma] = helm_dir_eig(chnkr);

[dp,varargout] = helm_dprime(zk,chnkr,sigma);

% dp = reshape(dp, chnkr.k, chnkr.nch);
% take maxi of dp
% fun = chebfun(dp(:, zero_loc), chebab, chebfunpref);
% gradu = abs(fun(0));

% res = integrate_u2norm[chnkr, sigma]

% loss =  - gradu/(res * sqrt(abs(e_val)))



