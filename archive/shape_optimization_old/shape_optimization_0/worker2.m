clear;clc;addpath('../src');


% Computes the gradient of objective when all sides are equal

num_verts = 5;

fprintf('Computing gradient for %d equal rs', num_verts);


even = ~mod(num_verts, 2);
num_rs = ceil(num_verts/2);

% Normalize side length so that the area is roughly 1
init_weight = ones(1, num_rs)/sqrt(pi/2);

% Choose the correct loss function
if even
    fun = @polysymeven_loss
else
    fun = @polysymodd_loss
end

% Compute grad for hspace = 0.005, 0.01, 0.015

hspaces = [0.005 0.01 0.015];
[temp, num_hspaces] = size(hspaces);
grads = zeros(num_hspaces, num_rs);

for i = 1:num_hspaces
    hspace = hspaces(i);
    fprintf('Computing gradient for h = %5.2e', hspace);
    start = tic; 
    grads(i,:) = optim.gd_grad(fun, init_weight, hspace);
    fprintf('Time used: %5.2e', toc(start));
end

disp(grads)