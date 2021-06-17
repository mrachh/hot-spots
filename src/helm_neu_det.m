function detfun = helm_neu_det(zk,chnkr,opts)
    fkern = @(s,t) chnk.helm2d.kern(zk,s,t,'D',1);

    start = tic; dmat = chunkermat(chnkr,fkern);
    t1 = toc(start);



    sys = eye(chnkr.k*chnkr.nch) + 2*dmat;
    detfun = det(sys);

end