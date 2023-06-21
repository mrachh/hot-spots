clear;
n = 16;
bottom = 0.3;
a = 1;
b = 1.5;
[verts, angles, rads] = initialize_polygon_vertices(n,bottom,a,b);
rads(4) = 0.1;
rads(5) = 0.2;
rads(11) = 0.2;
rads(16) = 0.1;
rads(1) = 0.1;
verts = compute_polygon_vertices(angles, rads);
figure(1)
scatter(verts(1,:),verts(2,:));
conv_rads = convexify(angles,rads);

figure(2)
verts = compute_polygon_vertices(angles, conv_rads);
scatter(verts(1,:),verts(2,:));
