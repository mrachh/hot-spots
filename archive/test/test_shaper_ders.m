addpath ../src
addpath ../archive/src
addpath ../src_shaper_ders/

ry_ratio = 1.5;
cy_ratio = 0.5;
dump_idx = 1;
cx = 0.1;
rx = 1;
n = 4;
ry = rx*ry_ratio;
cy = cy_ratio*ry;

init_rads = initialize_ellipse(rx,ry,cx,cy,n);
init_rads = init_rads/mean(init_rads);
init_angles = initialize_angles(n);
h = 1e-2;
max_iter = 1;
min_step_size = 1e-8;
maxchunklen = 0.1;
dump_dir = sprintf('./gd_ellipse%d',dump_idx);


n = length(init_angles);

mean_rads = 1;
angles = init_angles;
rads = init_rads;
rads = mean_rads*rads/mean(rads);
verts = compute_polygon_vertices(angles, rads);
chebabs = [2.0,6.0];


p = [];
p.k = 16; p.dim = 2;
cparams = [];
cparams.rounded = true;
cparams.autowidths = true;
cparams.smoothwidths = true;

[chnkr0, igrad0] = chunkerpoly(verts, cparams, p);
refopts = [];
refopts.maxchunklen = 0.1;
chnkr0 = refine(chnkr0, refopts);
chnkr0 = sort(chnkr0);

[~, nv] = size(verts);
%%
[~,~,~,dist,tn,ichn] = nearest(chnkr0, [0;0]);

%% define perturbations
dh = 0.01;
pert = zeros(2, nv);
pert(1,2) = 1;
nt = 4;

i1 = 3;
i2 = i1 + 2*nv;
i3 = i1 + 4*nv;
i4 = i1 + 2*nv + 4*nv;

chnkr1 = chnkr0;

%% Test derivative of speed and normal
dd = lege.dermat(16);

grad = vertgrad(chnkr1, igrad0, nv);
grads = vertdsdtgrad(chnkr1, igrad0, nv);

g = grad*pert(:);
gx = g(1:2:end); gy = g(2:2:end);


%%

gg = reshape(full(grad.'),4*nv,16,[]);
grads = reshape(full(grads.'),2*nv,16,[]);
chnkr1 = chnkr1.cleardata;

chnkr1 = chnkr1.makedatarows(8*nv+2*nv);

gradp  = permute(gg,[2,1,3]);
grad_d = pagemtimes(dd,gradp);
grad_d = ipermute(grad_d,[2,1,3]);

chnkr1.data(1:(2*2*nv),:,:) = gg;
chnkr1.data((2*2*nv+1):(2*2*2*nv),:,:) = grad_d;
chnkr1.data((2*2*2*nv+1):end,:,:) = grads;

%%

amin = 2;
bmin = 4;
ncheb = 32;


% t2 = tic; [val2, zk2, sig2, mu2, bie_norm2, sysmat] = ...
%      obj_fun(chnkr0, amin, bmin, ncheb); t2obj = toc(t2);

%%
t1 = tic; [val, zk, sig, mu, bie_norm, F] = ...
      obj_fun_flam(chnkr1, tn, ichn, amin, bmin, ncheb); t1obj = toc(t1);
fprintf('Time to compute eig fast     = %d\n',t1obj)
%%

tstart = tic; [dvals, dzks] = get_grads_fmm(chnkr1, tn, ichn, sig, mu, zk, bie_norm, F, nv);
tend = toc(tstart);
fprintf('Time to compute grad fast    = %d\n',tend)
%%

% tstart2 = tic; [dvals2, dzks2] = get_grads(chnkr1, sig, mu, zk, bie_norm, sysmat, nv);
% tend2 = toc(tstart2);

%%
% fprintf('Time to compute eig densely  = %d\n',t2obj)

% fprintf('Time to compute grad densely = %d\n',tend2)

% fprintf('error in dvals               = %d\n', norm(dvals-dvals2))


function [grad] = vertgrad(chnkr, igall, nvert)
%VERTGRAD gradient of chunk polygon nodes with respect to each vertex
%
% Syntax: 
%   grad = vertgrad(chnkr)
%
% Input:
%
% chnkr - chunk polygon object
%
% Output:
%
% grad - is a sparse 
%           (chnkr.dim \cdot chnkr.npts) x (chnkr.dim \cdot chnkr.nvert) 
%        matrix which gives the gradient of the chunker coordinates with 
%        respect to the vertex locations
%

dim = chnkr.dim;
npt = chnkr.npt;

grad = sparse(dim*npt,dim*nvert);

itmp1 = [0,(1:(nvert-1))];
itmp2 = 1:nvert; 

igrad = [1;0] +dim^2* [itmp1;itmp2];
isgrad = [dim^2*nvert+1;dim^2*nvert] + dim * [itmp1;itmp2];
ig = igall(igrad); ig = reshape(ig,[],nvert);
isg = igall(isgrad);

for i = 1:nvert
    jshift = (i-1)*chnkr.dim;
    j1 = 1:dim; j1 = j1(:); 
    
    ipts = 1:chnkr.npt; ipts = ipts(:);
    i1 = repmat(j1.',dim,1); i1 = i1(:);
    ii = i1 + (ipts.' - 1)*dim; ii = ii(:);
    n1 = numel(ipts);
    jj = repmat(j1,n1*dim,1); jj = jshift + jj(:);
    igi = ig(1,i):ig(2,i); igi=igi(:);
    vv = chnkr.data(igi,:,:); vv = vv(:);
    
    grad = grad + sparse(ii,jj,vv,dim*npt,dim*nvert);
    
end

end



function grad = vertdsdtgrad(chnkr, igall, nvert)
%VERTDSDTGRAD gradient of chunk arclength density with respect to each 
% vertex
%
% Syntax: 
%   grad = vertgrad(chnkr)
%
% Input:
%
% chnkr - chunk polygon object
%
% Output:
%
% grad - is a sparse 
%           (chnkr.npts) x (chnkr.dim \cdot chnkr.nvert) 
%        matrix which gives the gradient of the chunker coordinates with 
%        respect to the vertex locations
%


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

