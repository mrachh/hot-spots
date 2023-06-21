n = 8;
bottom = 0.3;
a = 1;
b = 1.5;
h = 1e-3;
min_step_size = 1e-6;
max_iter = 1000;
currentDir = pwd;
parentDir = fileparts(currentDir);
cd(parentDir);
startup
dump_dir = '~/shape_optimization_resultsv6/gd8';
result = gdv6(dump_dir, n,bottom,a,b,h,min_step_size,max_iter);