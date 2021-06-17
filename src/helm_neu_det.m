function [detfun,varargout] = helm_neu_det(zk,chnkr,opts)
%HELM_NEU_DET evaluates the Fredholm determinant for the interior 
%neumann problem for the helmholtz equation using the representation
% I + 2*D
%
% Syntax: detfun = helm_neu_det(zk,chnkr,opts)
% Input:
%   zk - Helmholtz wave number
%   chnkr - chunker object description of curve
% Optional input:
%   opts - structure for setting various parameters
%       opts.flam - if = true, use flam utilities (true)
%       opts.eps = tolerance for adaptive integration
% output:
%   detfun - Fredholm determinant of I + 2*D




flam = true;
eps = 1e-12;

if(nargin < 3) opts = []; end
    
    
if isfield(opts,'flam'); flam = opts.flam; end
if isfield(opts,'eps'); eps = opts.eps; end
    
    
fkern = @(s,t) 2*chnk.helm2d.kern(zk,s,t,'D',1);
opdims = [1 1];

if ~flam
    dmat = chunkermat(chnkr,fkern);
    sys = eye(chnkr.k*chnkr.nch) + dmat;
    detfun = det(sys);
else
    wts = weights(chnkr);
    optsquad = [];
    optsquad.nonsmoothonly = true;
    spmat = chunkermat(chnkr,fkern,optsquad);
    spmat = spmat + speye(chnkr.k*chnkr.nch);

    xflam = chnkr.r(:,:);
    opdims = [1 1];
    matfun = @(i,j) chnk.flam.kernbyindex(i,j,chnkr,wts,fkern,opdims,spmat);
    ifaddtrans = true;
    pxyfun = @(x,slf,nbr,l,ctr) chnk.flam.proxyfun(slf,nbr,l,ctr,chnkr,wts, ...
        fkern,opdims,pr,ptau,pw,pin,ifaddtrans);
    F = rskelf(matfun,xflam,200,1e-14,pxyfun); 
    varargout{1} = F;
    detfun = exp(rskelf_logdet(F));
end

end