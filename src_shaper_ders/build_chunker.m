function [chnkr, nv, tn, ichn] = build_chunker(verts)

    p = []; p.k = 16; p.dim = 2;
    cparams = [];
    cparams.rounded = true;
    cparams.autowidths = true;
    cparams.smoothwidths = true;
    
    [chnkr0, igrad0] = chunkerpoly(verts, cparams, p);
    refopts = []; 
    chnkr0 = sort(refine(chnkr0, refopts));
    
    
    [~, nv] = size(verts);
    [~,~,~,~,tn,ichn] = nearest(chnkr0, [0;0]);
    
    chnkr = chnkr0;
    dd = lege.dermat(p.k);
    
    grad_xy = vertgrad(chnkr, igrad0, nv);
    grad_s  = vertdsdtgrad(chnkr, igrad0, nv);
    
    gg  = reshape(full(grad_xy.'), 4*nv, p.k, []);
    grs = reshape(full(grad_s.' ), 2*nv, p.k, []);
    
    chnkr = chnkr.cleardata;
    chnkr = chnkr.makedatarows(8*nv + 2*nv);
    
    gradp  = permute(gg,[2,1,3]);
    grad_d = pagemtimes(dd,gradp);
    grad_d = ipermute(grad_d,[2,1,3]);
    
    chnkr.data(1:(2*2*nv),:,:)            = gg;
    chnkr.data((2*2*nv+1):(2*2*2*nv),:,:) = grad_d;
    chnkr.data((2*2*2*nv+1):end,:,:)      = grs;
    
        function grad = vertgrad(chnkr, igall, nvert)
            dim = chnkr.dim; npt = chnkr.npt;
            grad = sparse(dim*npt,dim*nvert);
            itmp1 = [0,(1:(nvert-1))]; itmp2 = 1:nvert;
            igrad = [1;0] + dim^2*[itmp1;itmp2];
            ig = igall(igrad); ig = reshape(ig,[],nvert);
            for i = 1:nvert
                jshift = (i-1)*chnkr.dim; j1 = (1:dim).';
                ipts = (1:chnkr.npt).';
                i1 = repmat(j1.',dim,1); i1 = i1(:);
                ii = i1 + (ipts.' - 1)*dim; ii = ii(:);
                n1 = numel(ipts); jj = repmat(j1,n1*dim,1); jj = jshift + jj(:);
                igi = ig(1,i):ig(2,i); vv = chnkr.data(igi,:,:); vv = vv(:);
                grad = grad + sparse(ii,jj,vv,dim*npt,dim*nvert);
            end
        end
    
        function grad = vertdsdtgrad(chnkr, igall, nvert)
            dim = chnkr.dim; npt = chnkr.npt;
            grad = sparse(npt,dim*nvert);
            itmp1 = [0,(1:(nvert-1))]; itmp2 = 1:nvert;
            isgrad = [dim^2*nvert+1;dim^2*nvert] + dim*[itmp1;itmp2];
            isg = igall(isgrad);
            for i = 1:nvert
                jshift = (i-1)*chnkr.dim; j1 = (1:dim).';
                ipts = (1:chnkr.npt).'; ii = repmat(ipts.',dim,1); ii = ii(:);
                n1 = numel(ipts); jj = repmat(j1,n1,1); jj = jshift + jj(:);
                isgi = isg(1,i):isg(2,i); vv = chnkr.data(isgi,:,:); vv = vv(:);
                grad = grad + sparse(ii,jj,vv,npt,dim*nvert);
            end
        end
    end
    