function res = rectangle(width)
    addpath('../src');
    % INPUT: width size 1 real
    % OUTPUT: res size 1 real
    %     let lamb be the first eval and u be an evec
    %     res = a/b, where
    %         a = L-inf norm of grad u
    %         b = sqrt{lamb} * 2-norm(u)

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Rectangle parametrization:
        % vertices:
        %     height = 1.0/width
        %     [-weight/2 0]       [weight/2 0]
        %     [weight/2 height]   [-weight/2 height]


    % Create chunker object
    verts = [-weight/2 0],  [weight/2 0]  [weight/2 height]   [-weight/2 height]

    res = 0;

end

