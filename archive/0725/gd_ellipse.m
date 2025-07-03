function result = gd_ellipse(ry_ratio,cy_ratio,dump_idx)
%ry_ratio = [0.1, 0.25, 0.5, 1, 1.5, 2, 3];
%cy_ratio = [-0.2, 0, 0.5, 0.9];
    cluster_setup;
    cx = 0.1;
    rx = 1;
    n = 16;
    ry = rx*ry_ratio;
    cy = cy_ratio*ry;
    n
    ry_ratio
    cy_ratio
    dump_idx
    init_rads = initialize_ellipse(rx,ry,cx,cy,n);
    init_rads = init_rads/mean(init_rads);
    init_angles = initialize_angles(n);
    h = 1e-2;
    max_iter = 1000;
    min_step_size = 1e-8;
    maxchunklen = 0.1;
    dump_dir = sprintf('/home/zw395/so0725/gd_ellipse%d',dump_idx);
    result = gd(dump_dir, h, min_step_size, max_iter, init_angles, init_rads, maxchunklen);
end
