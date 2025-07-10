function [dzk, dsig, dnorm, der_sig, dval] = get_grad_v_fast(chnkr0, sig, mu, ...
                                             zk, bie_norm, sysinv, vfunc)

K = kernel('helmholtz_shape_der', 'sp', zk, vfunc);
Mtot = chunkermat(chnkr0, K);
SpDk_ker  = kernel('helmholtz_shape','spdk', zk);
SpDk = chunkermat(chnkr0, SpDk_ker);

wts = weights(chnkr0);
mu_wts = (mu(:).*wts(:)).';
d_inn_prod_num = mu_wts*Mtot*sig;
d_inn_prod_den = mu_wts*SpDk*sig;
dzk = -d_inn_prod_num/d_inn_prod_den;
err_dzk = abs(imag(dzk));
dzk = real(dzk);

%%

rhs = 2*Mtot*sig + dzk*2*SpDk*sig;

dsig = sysinv*rhs;
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

sigpan = sig(1:16);
datpan = chnkr0.data(1,1:16).';
nlege = 16;
[xl,wl,ul,vl] = lege.exps(nlege);
cfs = ul*sigpan;
cfst= ul*datpan;

[ps] = lege.pols(-1,nlege-1);
err_sig_cfs = sum(abs(cfs(end-1:end)))/norm(cfs);
sigval = cfs.'*ps;

sigpan = dsig(1:16);
datpan = chnkr0.data(1,1:16).';
nlege = 16;
[xl,wl,ul,vl] = lege.exps(nlege);
cfs = ul*sigpan;
cfst= ul*datpan;

[ps] = lege.pols(-1,nlege-1);
err_sig_cfs = sum(abs(cfs(end-1:end)))/norm(cfs);
der_sig = cfs.'*ps;

%%

dval = der_sig/zk^2/sqrt(bie_norm);
dval = dval -2* dzk*sigval/zk^3/sqrt(bie_norm);
dval = dval -1/2*sigval/zk^2/(bie_norm)^(3/2)*dnorm;



end