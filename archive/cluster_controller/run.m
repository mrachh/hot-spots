function result = run(mat_fn)

    start = tic;
    mat_fn
    load(mat_fn);

    chebabs = [cheb_left, cheb_right];

    currentDir = pwd;
    parentDir = fileparts(currentDir);
    cd(parentDir);
    startup;

    loss_params = struct(...
    'default_chebabs',      chebabs, ...
    'udnorm_ord',              'inf', ...
    'unorm_ord',                  '2' ...
    );

    [loss, zk, ud_p, u_q, err_nullvec] = compute_loss(verts, loss_params, chebabs, maxchunklen);
    time = toc(start);
    
    n = size(verts, 2);

    nonconvex_penalty = 0.0;
    for i = 2:(n-1)
        x1 = verts(1,i-1)-verts(1,i);
        x2 = verts(1,i+1)-verts(1,i);
        y1 = verts(2,i-1)-verts(2,i);
        y2 = verts(2,i+1)-verts(2,i);
        v1 = [x1 y1 0];
        v2 = [x2 y2 0];
        v3 = [0 0 -1];
        x = cross(v1,v2);
        c = sign(dot(x,v3)) * norm(x);
        inner_angle = mod(atan2d(c,dot(v1,v2)),360)/180;
        if inner_angle>nonconvex_threshold+1.0
            nonconvex_penalty = nonconvex_penalty + (inner_angle-1.0-nonconvex_threshold)^2;
        end
    end
    nonconvex_penalty = nonconvex_penalty*nonconvex_penalty_factor;
    loss = loss + nonconvex_penalty;
    
    save(save_fn);
end
