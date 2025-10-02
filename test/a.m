clear; clc;

addpath ../src
addpath ../src_shaper_ders/
cluster_startup;

% parameters
n        = 8;
ncheb    = 32;
ycenter  = 0.98;
maxiter  = 100;
stepsize = 1.0;
zk0      = 2.0;
savefile = 'checkpoint.mat';
resume   = false;   % set true to resume, false to restart

run_gradient_descent(n, ncheb, ycenter, maxiter, stepsize, zk0, savefile, resume);

S = load(savefile);
fprintf('\nFinal iteration = %d\n', S.iter);
fprintf('Final val       = %.12e\n', S.vals(end));
fprintf('Final zk        = %.12e\n', S.zks(end));
fprintf('Norm of rads    = %.12e\n', norm(S.rads));

