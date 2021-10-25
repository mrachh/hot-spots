function [flag,corr] = get_flags_corr(chnkr,zk,targs)
%CHUNKERKERNEVAL_withcorr compute the convolution of the integral kernel 
% with the density defined on the chunk geometry, where near correction
% to target potentials are precomputed, the kernel is the combined field 
% integral equation
%
% Syntax: fints = chunkerkerneval(chnkr,kern,dens,targs,opts)
%
% Input:
%   chnkr - chunker object description of curve
%   dens - density on boundary, should have size opdims(2) x k x nch
%          where k = chnkr.k, nch = chnkr.nch, where opdims is the 
%           size of kern for a single src,targ pair
%   targs - targ(1:2,i) gives the coords of the ith target
%
% output:
%   flags - sparse array representation for which targets are close
%        to boundary
%    corr - matrix correction for near field stuff


% determine operator dimensions using first two points


srcinfo = []; targinfo = [];
srcinfo.r = chnkr.r(:,1); srcinfo.d = chnkr.d(:,1); 
srcinfo.d2 = chnkr.d2(:,1);
targinfo.r = chnkr.r(:,2); targinfo.d = chnkr.d(:,2); 
targinfo.d2 = chnkr.d2(:,2);
kern = @(s,t) chnk.helm2d.kern(zk,s,t,'c',1);

ftemp = kern(srcinfo,targinfo);
opdims = size(ftemp);

if nargin < 5
    opts = [];
end

fac = 0.1;
quadgkparams = {};
eps = 1e-7;

[dim,~] = size(targs);

if (dim ~= 2); warning('only dimension two tested'); end

optssmooth = []; 
optsadap = []; optsadap.quadgkparams = quadgkparams;
optsadap.eps = eps;

% smooth for sufficiently far, adaptive otherwise

optsflag = []; optsflag.fac = fac;
flag = flagnear(chnkr,targs,optsflag);

[~,nt] = size(targs);
corr = complex(sparse(opdims(1)*nt,chnkr.k*chnkr.nch));

nch = chnkr.nch;
k = chnkr.k;

[~,w] = lege.exps(k);

targinfo = [];
if ~isempty(flag)
    for i = 1:nch
        dsdtdt = sqrt(sum(abs(chnkr.d(:,:,i)).^2,1));
        dsdtdt = dsdtdt(:).*w(:)*chnkr.h(i);
        dsdtdt = repmat( (dsdtdt(:)).',opdims(2),1);
        srcinfo = []; srcinfo.r = chnkr.r(:,:,i); 
        srcinfo.d = chnkr.d(:,:,i); srcinfo.d2 = chnkr.d2(:,:,i);

        delsmooth = find(flag(:,i)); 
        delsmoothrow = (opdims(1)*(delsmooth(:)-1)).' + (1:opdims(1)).';

        targinfo.r = targs(:,delsmooth);

        kernmat = kern(srcinfo,targinfo)*diag(dsdtdt(:));

        corr(delsmoothrow,(((i-1)*k+1):(i*k))) = -kernmat;
    end
end    

corr = corr + chunkerkernevalmat_adap_corr(chnkr,kern,opdims,targs,flag,...
    optsadap);

end


function mat = chunkerkernevalmat_adap_corr(chnkr,kern,opdims, ...
    targs,flag,opts)

k = chnkr.k;
nch = chnkr.nch;

if nargin < 5
    flag = [];
end
if nargin < 6
    opts = [];
end

[~,nt] = size(targs);

% using adaptive quadrature


if isempty(flag)
    mat = zeros(opdims(1)*nt,opdims(2)*chnkr.npt);

    [t,w] = lege.exps(2*k+1);
    ct = lege.exps(k);
    bw = lege.barywts(k);
    r = chnkr.r;
    d = chnkr.d;
    d2 = chnkr.d2;
    h = chnkr.h;
    targd = zeros(chnkr.dim,nt); targd2 = zeros(chnkr.dim,nt);    
    for i = 1:nch
        jmat = 1 + (i-1)*k*opdims(2);
        jmatend = i*k*opdims(2);
                        
        mat(:,jmat:jmatend) =  chnk.adapgausswts(r,d,d2,h,ct,bw,i,targs, ...
                    targd,targd2,kern,opdims,t,w,opts);
                
        js1 = jmat:jmatend;
        js1 = repmat( (js1(:)).',1,opdims(1)*numel(ji));
                
        indji = (ji-1)*opdims(1);
        indji = repmat( (indji(:)).', opdims(1),1) + ( (1:opdims(1)).');
        indji = indji(:);
        indji = repmat(indji,1,opdims(2)*k);
        
        iend = istart+numel(mat1)-1;
        is(istart:iend) = indji(:);
        js(istart:iend) = js1(:);
        vs(istart:iend) = mat1(:);
        istart = iend+1;
    end
    
else
    is = zeros(nnz(flag)*opdims(1)*opdims(2)*k,1);
    js = is;
    vs = is;
    istart = 1;

    [t,w] = lege.exps(2*k+1);
    ct = lege.exps(k);
    bw = lege.barywts(k);
    r = chnkr.r;
    d = chnkr.d;
    d2 = chnkr.d2;
    h = chnkr.h;
    targd = zeros(chnkr.dim,nt); targd2 = zeros(chnkr.dim,nt);
    for i = 1:nch
        jmat = 1 + (i-1)*k*opdims(2);
        jmatend = i*k*opdims(2);
                        
        [ji] = find(flag(:,i));
        mat1 =  chnk.adapgausswts(r,d,d2,h,ct,bw,i,targs(:,ji), ...
                    targd(:,ji),targd2(:,ji),kern,opdims,t,w,opts);
                
        js1 = jmat:jmatend;
        js1 = repmat( (js1(:)).',opdims(1)*numel(ji),1);
                
        indji = (ji-1)*opdims(1);
        indji = repmat( (indji(:)).', opdims(1),1) + ( (1:opdims(1)).');
        indji = indji(:);
        
        indji = repmat(indji,1,opdims(2)*k);
        
        iend = istart+numel(mat1)-1;
        is(istart:iend) = indji(:);
        js(istart:iend) = js1(:);
        vs(istart:iend) = mat1(:);
        istart = iend+1;
    end
    mat = sparse(is,js,vs,opdims(1)*nt,opdims(2)*chnkr.npt);
    
end

end


