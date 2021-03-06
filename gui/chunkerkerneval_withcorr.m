function fints = chunkerkerneval_withcorr(chnkr,kern,dens,targs,flag,corr)
%CHUNKERKERNEVAL_withcorr compute the convolution of the integral kernel 
% with the density defined on the chunk geometry, where near correction
% to target potentials are precomputed.
%
% Syntax: fints = chunkerkerneval(chnkr,kern,dens,targs,opts)
%
% Input:
%   chnkr - chunker object description of curve
%   kern - integral kernel taking inputs kern(srcinfo,targinfo) 
%   dens - density on boundary, should have size opdims(2) x k x nch
%          where k = chnkr.k, nch = chnkr.nch, where opdims is the 
%           size of kern for a single src,targ pair
%   targs - targ(1:2,i) gives the coords of the ith target
%
% output:
%   fints - opdims(1) x nt array of integral values where opdims is the 
%           size of kern for a single input (dimension of operator output)
%
% see also QUADGK

% TODO: find a method for using proxy surfaces while still not performing
%   the add/subtract strategy...

% author: Travis Askham (askhamwhat@gmail.com)

% determine operator dimensions using first two points


srcinfo = []; targinfo = [];
srcinfo.r = chnkr.r(:,1); srcinfo.d = chnkr.d(:,1); 
srcinfo.d2 = chnkr.d2(:,1);
targinfo.r = chnkr.r(:,2); targinfo.d = chnkr.d(:,2); 
targinfo.d2 = chnkr.d2(:,2);

ftemp = kern(srcinfo,targinfo);
opdims = size(ftemp);

if nargin < 5
    opts = [];
end

forcesmooth = false;
forceadap = false;
flam = true;
fac = 1.0;
quadgkparams = {};
eps = 1e-12;

[dim,~] = size(targs);

if (dim ~= 2); warning('only dimension two tested'); end

optssmooth = []; optssmooth.flam = flam;
optsadap = []; optsadap.quadgkparams = quadgkparams;
optsadap.eps = eps;

fints = chunkerkerneval_smooth_corr(chnkr,kern,opdims,dens,targs, ...
    flag,corr);

%fints = fints + chunkerkerneval_adap_corr(chnkr,kern,opdims,dens, ...
%        targs,flag,optsadap);


end



function fints = chunkerkerneval_smooth_corr(chnkr,kern,opdims,dens, ...
    targs,flag,corr)

flam = true;

if nargin < 6
    flag = [];
end
if nargin < 7
    opts = [];
end


k = chnkr.k;
nch = chnkr.nch;

assert(numel(dens) == opdims(2)*k*nch,'dens not of appropriate size')
dens = reshape(dens,opdims(2),k,nch);

[~,w] = lege.exps(k);
[~,nt] = size(targs);

fints = zeros(opdims(1)*nt,1);
densvals = dens(:);

targinfo = []; targinfo.r = targs;

%     % hack to ignore interactions: create sparse array with very small
%     % number instead of zero in ignored entries. kernbyindexr overwrites
%     %   with that small number
%     [i,j] = find(flag);
%     
%     % targets correspond to multiple outputs (if matrix valued kernel)
%     inew = (opdims(1)*(i(:)-1)).' + (1:opdims(1)).'; inew = inew(:);
%     jnew = (j(:)).' + 0*(1:opdims(1)).'; jnew = jnew(:);
%     
%     % source chunks have multiple points and can be multi-dimensional
%     jnew = (opdims(2)*chnkr.k*(jnew(:)-1)).' + (1:(chnkr.k*opdims(2))).';
%     jnew = jnew(:);
%     inew = (inew(:)).' + 0*(1:(chnkr.k*opdims(2))).';
%     inew = inew(:);
%     
%     mm = nt*opdims(1); nn = chnkr.npt*opdims(2);
%     v = 1e-300*ones(length(inew),1); sp = sparse(inew,jnew,v,mm,nn);
    wts = weights(chnkr);
    wts = repmat((wts(:)).',opdims(2),1); wts = wts(:);
    
    xflam1 = chnkr.r(:,:);
    xflam1 = repmat(xflam1,opdims(2),1);
    xflam1 = reshape(xflam1,chnkr.dim,numel(xflam1)/chnkr.dim);
    targsflam = repmat(targs(:,:),opdims(1),1);
    targsflam = reshape(targsflam,chnkr.dim,numel(targsflam)/chnkr.dim);
%    matfun = @(i,j) chnk.flam.kernbyindexr(i,j,targs,chnkr,wts,kern, ...
%        opdims,sp);
    matfun = @(i,j) chnk.flam.kernbyindexr(i,j,targs,chnkr,wts,kern, ...
        opdims);
    
    width = max(abs(max(chnkr)-min(chnkr)))/3;
    tmax = max(targs(:,:),[],2); tmin = min(targs(:,:),[],2);
    wmax = max(abs(tmax-tmin));
    width = max(width,wmax/3);
    npxy = chnk.flam.nproxy_square(kern,width);
    [pr,ptau,pw,pin] = chnk.flam.proxy_square_pts(npxy);

    pxyfun = @(rc,rx,cx,slf,nbr,l,ctr) chnk.flam.proxyfunr(rc,rx,slf,nbr,l, ...
        ctr,chnkr,wts,kern,opdims,pr,ptau,pw,pin);
    F = ifmm(matfun,targsflam,xflam1,200,1e-14,pxyfun);
    fints = ifmm_mv(F,dens(:),matfun);
   
    
    fints = fints + corr*densvals;
end

function fints = chunkerkerneval_adap_corr(chnkr,kern,opdims,dens, ...
    targs,flag,opts)

k = chnkr.k;
nch = chnkr.nch;

if nargin < 6
    flag = [];
end
if nargin < 7
    opts = [];
end

quadgkparams = {};
if isfield(opts,'quadgkparams')
    quadgkparams = opts.quadgkparams;
end

assert(numel(dens) == opdims(2)*k*nch,'dens not of appropriate size')
dens = reshape(dens,opdims(2),k,nch);

[~,~,u] = lege.exps(k);
[~,nt] = size(targs);

fints = zeros(opdims(1)*nt,1);

% using adaptive quadrature


if isempty(flag)
    [rc,dc,d2c] = exps(chnkr);
    for i = 1:nch
        rci = rc(:,:,i);
        dci = dc(:,:,i);
        d2ci = d2c(:,:,i);    
        densvals = dens(:,:,i); densvals = densvals.';
        densc = u*densvals; % each column is set of coefficients
                        % for one dimension of density on chunk
        for j = 1:nt
            indj = (j-1)*opdims(1);
            for l = 1:opdims(1)
                ind = indj+l;
                temp = chnk.intchunk.kerncoefs(kern,opdims,l,...
                    densc,rci,dci,d2ci,targs(:,j),quadgkparams);

                fints(ind) = fints(ind) + temp*chnkr.h(i);
            end
        end
    end
else
%     [rc,dc,d2c] = exps(chnkr);
    [t,w] = lege.exps(2*k+1);
    ct = lege.exps(k);
    bw = lege.barywts(k);
    r = chnkr.r;
    d = chnkr.d;
    d2 = chnkr.d2;
    h = chnkr.h;
    targd = zeros(chnkr.dim,nt); targd2 = zeros(chnkr.dim,nt);
    for i = 1:nch
%         rci = rc(:,:,i);
%         dci = dc(:,:,i);
%         d2ci = d2c(:,:,i);    
%         densvals = dens(:,:,i); densvals = densvals.';
%         densc = u*densvals; % each column is set of coefficients
%                         % for one dimension of density on chunk
                        
        [ji] = find(flag(:,i));
        fints1 =  chnk.adapgausskerneval(r,d,d2,h,ct,bw,i,dens,targs(:,ji), ...
                    targd(:,ji),targd2(:,ji),kern,opdims,t,w,opts);
                
        indji = (ji-1)*opdims(1);
        fints(indji+(1:opdims(1))) = fints(indji+(1:opdims(1))) + fints1;
        
%        for jj = 1:length(ji)
%            j = ji(jj);
%            indj = (j-1)*opdims(1);
%             for l = 1:opdims(1)
%                 ind = indj+l;
%                 temp = chnk.intchunk.kerncoefs(kern,opdims,l,...
%                     densc,rci,dci,d2ci,targs(:,j),quadgkparams);
% 
%                 fints(ind) = fints(ind) + temp*chnkr.h(i);
%             end
%        end

    end
    
end

end

