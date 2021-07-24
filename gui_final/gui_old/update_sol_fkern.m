function [F, sol] = update_sol_fkern(chnkr, direction, zk)
    addpath('../src');

    % app.F, app.sol = update_sol_fkern(...
    %    app.chnkr, app.knob_direction.Value, app.knob_zk.Value)
    
    direction = direction * 2.0 * pi / 360.0;
    kvec = zk .* [cos(direction); sin(direction)];
    fkern = @(s,t) chnk.helm2d.kern(zk,s,t,'c',1);
    opdims(1) = 1; opdims(2) = 1;
    opts = [];
    rhs = -planewave(kvec(:),chnkr.r(:,:)); rhs = rhs(:);
    
    % Solve for sol
    %fds
    dval = 0.5;
    opts_flam = [];
    opts_flam.flamtype = 'rskelf';
    F = chunkerflam(chnkr,fkern,dval,opts_flam);
    start = tic; sol = rskelf_sv(F,rhs); t_fds = toc(start);
    disp(sol(2))

end