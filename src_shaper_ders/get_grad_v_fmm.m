function [dzk, dsig, dnorm, der_sig, dval] = get_grad_v_fmm(chnkr0, tn, ...
                                             ichn, sig, mu, zk, bie_norm, ...
                                             F, vfunc)
opts = [];
opts.corrections = true;
K = kernel('helmholtz_shape_der', 'sp', zk, vfunc);
Mtot = chunkermat(chnkr0, K, opts);
SpDk_ker = kernel('helmholtz_shape','spdk', zk, opts);
SpDk = chunkermat(chnkr0, SpDk_ker, opts);

wts = weights(chnkr0);
mu_wts = (mu(:).*wts(:)).';


% Compute SpDk*sig

srcinfo = [];
srcinfo.sources = chnkr0.r(:,:);
[~, n] = size(srcinfo.sources);
srcinfo.nd = 3;
srcinfo.charges = complex(zeros(3,n));
srcinfo.charges(1,:) = (sig.*chnkr0.wts(:)).';
srcinfo.charges(2,:) = (sig.*chnkr0.wts(:)).'.*chnkr0.r(1,:);
srcinfo.charges(3,:) = (sig.*chnkr0.wts(:)).'.*chnkr0.r(2,:);

pg = 1;
U = hfmm2d(1e-7, zk, srcinfo, pg);

rnt = chnkr0.r(1,:).*chnkr0.n(1,:) + chnkr0.r(2,:).*chnkr0.n(2,:);
p1 = rnt.*U.pot(1,:);
p2 = chnkr0.n(1,:).*U.pot(2,:) + chnkr0.n(2,:).*U.pot(3,:);
SpDksig = (-zk*(p1 - p2)).' + SpDk*sig;

% Compute Mtot*sig

vx = chnkr0.data(vfunc(1),:);
vy = chnkr0.data(vfunc(2),:);
dvx = chnkr0.data(vfunc(3),:);
dvy = chnkr0.data(vfunc(4),:);

srcinfo = [];
srcinfo.sources = chnkr0.r(:,:);
[~, n] = size(srcinfo.sources);
srcinfo.nd = 3;
srcinfo.charges = complex(zeros(3,n));
srcinfo.charges(1,:) = (sig.*chnkr0.wts(:)).';
srcinfo.charges(2,:) = 0;
dden = (chnkr0.d(1,:).^2 + chnkr0.d(2,:).^2);
ddot = (dvx.*chnkr0.d(1,:) + dvy.*chnkr0.d(2,:))./dden;
srcinfo.charges(3,:) = (sig.*chnkr0.wts(:)).'.*ddot;

srcinfo.dipstr = complex(zeros(3,n));
srcinfo.dipvec = zeros(3,2,n);
srcinfo.dipstr(2,:) = (sig.*chnkr0.wts(:)).';
srcinfo.dipvec(2,1,:) = vx;
srcinfo.dipvec(2,2,:) = vy;

pg = 3;
U2 = hfmm2d(1e-7, zk, srcinfo, pg);


t1 = (squeeze(U2.grad(1,1,:)).'.*dvy - ...
    squeeze(U2.grad(1,2,:)).'.*dvx)./sqrt(dden);

t2 = (squeeze(U2.hess(1,1,:)).'.*chnkr0.n(1,:).*vx + ...
      squeeze(U2.hess(1,2,:)).'.*(chnkr0.n(1,:).*vy + chnkr0.n(2,:).*vx) +...
      squeeze(U2.hess(1,3,:)).'.*chnkr0.n(2,:).*vy);

t3 = (squeeze(U2.grad(2,1,:)).'.*chnkr0.n(1,:) + ...
    squeeze(U2.grad(2,2,:)).'.*chnkr0.n(2,:));

t4 = (squeeze(U2.grad(3,1,:)).'.*chnkr0.n(1,:) + ...
    squeeze(U2.grad(3,2,:)).'.*chnkr0.n(2,:));

t5 = -(squeeze(U2.grad(1,1,:)).'.*chnkr0.n(1,:) + ...
    squeeze(U2.grad(1,2,:)).'.*chnkr0.n(2,:)).*ddot;

Mtotsig = (t1 + t2 + t3 + t4 + t5).' + Mtot*sig;



d_inn_prod_num = mu_wts*Mtotsig;
d_inn_prod_den = mu_wts*SpDksig;
dzk = -d_inn_prod_num/d_inn_prod_den;
err_dzk = abs(imag(dzk));
dzk = real(dzk);

%%

rhs = 2*Mtotsig + dzk*2*SpDksig;

v = sig.*wts(:);
u = mu(:);
A = @(x) rskelf_plus_mv(x,F,u,v);
dsig = gmres(A, rhs, [], 1e-10, 200);
err_dsig = sqrt(sum(abs(imag(dsig)).^2.*wts(:)));
dsig = real(dsig);

%%


vfx = chnkr0.data(vfunc(1),:);
vfy = chnkr0.data(vfunc(2),:);
vsx = chnkr0.data(vfunc(3),:);
vsy = chnkr0.data(vfunc(4),:);

gam0 = chnkr0.r(:,:);
nor0 = chnkr0.n(:,:);
wts0 = weights(chnkr0);
wts0 = wts0(:).';
s0 = (sig.').^2/(2*zk^2);
ss0 = sig.';

dsdt = sqrt(chnkr0.d(1,:).^2 + chnkr0.d(2,:).^2);

t2 = s0.*(vfx.*nor0(1,:) + vfy.*nor0(2,:)).*wts0;
t2 = sum(t2);
t3 = s0.*(vsy.*gam0(1,:)-vsx(1,:).*gam0(2,:))./dsdt.*wts0;
t3 = sum(t3);
t4 = 1/zk^2*dsig.'.*ss0.*(gam0(1,:).*nor0(1,:)+gam0(2,:).*nor0(2,:)).*wts0;
t4 = sum(t4);
t5 = -2/zk*dzk*s0.*(gam0(1,:).*nor0(1,:)+gam0(2,:).*nor0(2,:)).*wts0;
t5 = sum(t5);

dnorm = t2 + t3 + t4 + t5;

%%

iinds = ((ichn-1)*chnkr0.k+1):(ichn*chnkr0.k);

sigpan = sig(iinds);
datpan = chnkr0.data(1,iinds).';
nlege = chnkr0.k;
[~,~,ul,~] = lege.exps(nlege);
cfs = ul*sigpan;
cfst= ul*datpan;

[ps] = lege.pols(tn,nlege-1);
err_sig_cfs = sum(abs(cfs(end-1:end)))/norm(cfs);
sigval = cfs.'*ps;

sigpan = dsig(iinds);
datpan = chnkr0.data(1,iinds).';
cfs = ul*sigpan;
cfst= ul*datpan;

[ps] = lege.pols(tn,nlege-1);
err_sig_cfs = sum(abs(cfs(end-1:end)))/norm(cfs);
der_sig = cfs.'*ps;

%%

dval = der_sig/zk^2/sqrt(bie_norm);
dval = dval -2* dzk*sigval/zk^3/sqrt(bie_norm);
dval = dval -1/2*sigval/zk^2/(bie_norm)^(3/2)*dnorm;



end


    
function y = rskelf_plus_mv(x,F,u,v)
    
    y = rskelf_mv(F, x, 'n');
    y = y+u*v.'*x;
    
end
