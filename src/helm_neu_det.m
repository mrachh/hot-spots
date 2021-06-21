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
dval = 1.0;
opts_flam = [];
opts_flam.flamtype = 'rskelf';
opts_flam.rank_or_tol = eps;



if ~flam
    dmat = chunkermat(chnkr,fkern);
    sys = eye(chnkr.k*chnkr.nch) + dmat;
    detfun = det(sys);
else
    F = chunkerflam(chnkr,fkern,dval,opts_flam);
    varargout{1} = F;
    detfun = exp(rskelf_logdet(F));
end

end