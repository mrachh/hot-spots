addpath ../src
addpath ../archive/src
addpath ../src_shaper_ders/
cluster_startup;

rx = 1; ry_ratio = 1.5; cy_ratio = 0.5; cx = 0.1; n = 8;
ry = rx*ry_ratio; cy = cy_ratio*ry;
init_rads   = initialize_ellipse(rx,ry,cx,cy,n);
init_rads   = init_rads/mean(init_rads);
init_angles = initialize_angles(n);
verts       = compute_polygon_vertices(init_angles, init_rads);

p = []; p.k = 16; p.dim = 2;
cparams = []; 
cparams.rounded = true; 
cparams.autowidths = true; 
cparams.smoothwidths = true;
[chnkr0, igrad0] = chunkerpoly(verts, cparams, p);
refopts = []; refopts.maxchunklen = 0.1;
chnkr0 = sort(refine(chnkr0, refopts));
[~, nv] = size(verts);
[~,~,~,~,tn,ichn] = nearest(chnkr0, [0;0]);
chnkr1 = chnkr0;
dd = lege.dermat(p.k);
grad_xy  = vertgrad(chnkr1, igrad0, nv);
grad_s   = vertdsdtgrad(chnkr1, igrad0, nv);
gg    = reshape(full(grad_xy.'), 4*nv, p.k, []);
grs   = reshape(full(grad_s.' ), 2*nv, p.k, []);
chnkr1 = chnkr1.cleardata;
chnkr1 = chnkr1.makedatarows(8*nv + 2*nv);
gradp  = permute(gg,[2,1,3]);
grad_d = pagemtimes(dd,gradp);
grad_d = ipermute(grad_d,[2,1,3]);
chnkr1.data(1:(2*2*nv),:,:)            = gg;
chnkr1.data((2*2*nv+1):(2*2*2*nv),:,:) = grad_d;
chnkr1.data((2*2*2*nv+1):end,:,:)      = grs;

% results
amin = 2; bmin = 4; ncheb = 32;

t1 = tic;
[val, zk, sig, mu, bie_norm, F] = obj_fun_flam(chnkr1, tn, ichn, amin, bmin, ncheb);
t1obj = toc(t1);
fprintf('Time for obj_fun_flam   = %.6f sec\n', t1obj);

t2 = tic;
[dvals, dzks] = get_grads_fmm(chnkr1, tn, ichn, sig, mu, zk, bie_norm, F, nv);
t2grad = toc(t2);
fprintf('Time for get_grads_fmm  = %.6f sec\n', t2grad);

fprintf('val = %.12e\n', val);
fprintf('zk  = %.12e\n', zk);
fprintf('norm(dvals) = %.12e\n', norm(dvals));

% helpers
function [grad] = vertgrad(chnkr, igall, nvert)
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
dim = chnkr.dim;
npt = chnkr.npt;

grad = sparse(npt,dim*nvert);

itmp1 = [0,(1:(nvert-1))];
itmp2 = 1:nvert; 

isgrad = [dim^2*nvert+1;dim^2*nvert] + dim * [itmp1;itmp2];
isg = igall(isgrad);

for i = 1:nvert
    jshift = (i-1)*chnkr.dim;
    j1 = 1:dim; j1 = j1(:); 
    
    ipts = 1:chnkr.npt; ipts = ipts(:);
    ii = repmat(ipts.',dim,1); ii = ii(:);
    n1 = numel(ipts);
    jj = repmat(j1,n1,1); jj = jshift + jj(:);
    isgi = isg(1,i):isg(2,i);
    vv = chnkr.data(isgi,:,:); vv = vv(:);
    
    grad = grad + sparse(ii,jj,vv,npt,dim*nvert);    
    
end

end