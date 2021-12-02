function [uscat] = compute_uscat_withcorr(chnkr, zk, sol, out, targets,flag,corr)
    addpath('../src');
    fkern = @(s,t) chnk.helm2d.kern(zk,s,t,'c',1);
    dens = sol(:);
    wts = weights(chnkr);
    wts = wts(:);
    rnorms = normals(chnkr);
    npts = chnkr.k*chnkr.nch;
    rnorms = reshape(rnorms,[2,npts]);
    r = chnkr.r;
    r = reshape(r,[2,npts]);
    srcinfo.charges = 1j*dens.*wts;
    srcinfo.dipstr = dens.*wts;
    srcinfo.sources = r;
    srcinfo.dipvec = rnorms;
    eps = 1e-7;
    uscat = hfmm2d(eps,zk,srcinfo,targets(1:2,out));
    uscat = uscat(:);
    uscat = uscat + corr*dens;
    %uscat = chunkerkerneval_withcorr(chnkr,fkern,sol,targets(:,out),flag,corr);
end
