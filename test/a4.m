clear; clc;

addpath ../src
addpath ../src_shaper_ders/
cluster_startup;

% parameters
n        = 6;
ncheb    = 32;
ycenter  = 0.98;
maxiter  = 100;
stepsize = 1.0;
zk0      = 2.0;
savedir = 'checkpoint4';
resume   = false;   % set true to resume, false to restart

gd_circlev4(n, ncheb, ycenter, maxiter, stepsize, zk0, savedir, resume);

