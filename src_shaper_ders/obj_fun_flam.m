function [val, zk, sig, mu, bie_norm, F, varargout] = obj_fun_flam(chnkr0, ...
                                        tn, ichn, amin, bmin, ncheb, opts)
%
%  This function computes the laplacian eigenvalue on the interval
%  [amin, bmin] using ncheb points and returns, 
%  the value of the objective function val, the eigenvalue zk, 
%  dudn given by sigma, mu which is the null vector of -2*D, bie_norm
%  which is the normalization factor, and F which is the flam compressed
%  representation at the eigenvalue.
%
%  The origin is at the point tn \in [-1,1] on chunk ichn
%
%  The routine can also be operated to return val, sig, mu, bie_norm, F
%  if the eigenvalue is known.
%
%

    if nargin < 7
        opts = [];
    end
    
    eps = 1e-7;
    if isfield(opts, 'eps')
        eps = opts.eps;
    end
    
    opts_flam = [];
    opts_flam.eps = eps;
    opts_flam.flamtype = 'rskelf';
    opts_flam.forceproxy = true;
    
    dval = 1.0;
    if ~isfield(opts, 'zk')
        x0 = cos(pi*(0:(ncheb-1))/(ncheb-1));
        xcheb = (bmin-amin)*(1+x0)/2+amin;
        ddets = zeros(size(xcheb));
        for ii=1:ncheb
            zk = xcheb(ii);
            Sp = -2*kernel('helmholtz','sprime',zk);
            F  = chunkerflam(chnkr0, Sp, dval, opts_flam);
            ddets(ii) = exp(rskelf_logdet(F));
        end
    
        ddets = ddets/max(abs(ddets));
    
        %%
        ns = 0:(ncheb-1);
        [NT,XT] = meshgrid(ns,x0);
        tmat = cos(NT.*acos(XT));
        ccoef = tmat\ddets.';
        
        %%
        cmat = spdiags(ones(2,ncheb).'/2,[-1,1],ncheb,ncheb);
        cmat(1,2) = 1/sqrt(2);
        cmat(2,1) = 1/sqrt(2);
        vvec = ccoef;
        vvec(1) = sqrt(2)*vvec(1);
        cmat(end,:) = cmat(end,:)-1/2*vvec.'/vvec(end);
        es = eigs(cmat,ncheb);
        es(abs(real(es))>0.9) = [];
        es(abs(imag(es))>1E-4) = [];
        eigval = min(real(es));
        eigval = (bmin-amin)*(eigval+1)/2+amin;
        
        err_eig_real = max(abs(imag(es)));
        varargout{1} = err_eig_real;
        zk = eigval(1);
    else
        zk = opts.zk;
    end
    
    Sp = -2*kernel('helmholtz','sprime',zk);
    F  = chunkerflam(chnkr0, Sp, dval, opts_flam);

    nsys = chnkr0.npt;
    sig = rskelf_nullvec(F, nsys, 1, 4);
    [~, i] = max(abs(sig));
    
    wts = weights(chnkr0);
    err_sig_real = norm(sqrt(wts(:).*imag(sig/sig(i)).^2));
    varargout{2} = err_sig_real;
    
    sig = real(sig/sig(i));
    sig_n = sum(sig.^2.*(wts(:)));
    sig = sig/sig_n;
    
    D = -2*kernel('helmholtz','d',zk);
    Fd = chunkerflam(chnkr0, D, dval, opts_flam);
    mu = rskelf_nullvec(Fd, nsys, 1, 4);
    [~,i] = max(abs(mu));
    mu = mu/mu(i);
    
    %%
    
    wts = weights(chnkr0);
    bfunc = chnkr0.r(1,:).*chnkr0.n(1,:)+chnkr0.r(2,:).*chnkr0.n(2,:);
    bie_norm = 1/zk^2*sum((sig.').^2.*bfunc.*wts(:).')/2;
    
    iinds = ((ichn-1)*chnkr0.k+1):(ichn*chnkr0.k);
    sigpan = sig(iinds);
    nlege = chnkr0.k;
    [~, ~, ul, ~] = lege.exps(nlege);
    cfs = ul*sigpan;
    
    [ps] = lege.pols(tn,nlege-1);
    der_sig = cfs.'*ps;
    
    
    val = der_sig/zk^2/sqrt(bie_norm);
    
    innprod = sum(sig.*mu.*wts(:));
    mu = mu/innprod;


end

