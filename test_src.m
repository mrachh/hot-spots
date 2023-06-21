clear;

n = 10;

% initialize polygon
bottom = 0.3;
a = 1;
b = 1.5;
[vertices, angles, rads] = initialize_polygon_vertices(10,bottom,a,b);
[chunker, center] = chunk_polygon(vertices);
plot_chunker(chunker)

loss_params = struct(...
'default_chebabs',      [1 10], ...
'udnorm_ord',              'inf', ...
'unorm_ord',                  '2' ...
);

% compute initial 6
[loss, chebabs, zk] = compute_loss(vertices, loss_params, [1 6]);
