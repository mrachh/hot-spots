% shows the limit of the equation tends to 1/xi
addpath('~/matlab_packages/bessel_zero');
xi = besselzero(1,1);
% besselj(1,xi)
lims = zeros(1,10);
for i = 1:30
    eps = 10^(-i/5.0);
    z = xi+eps;
    lim = besselj(2,z)/(2*besselj(1,z))+z/(z^2-xi^2);
    lims(i) = lim;
end
figure()
plot(log10(abs(lims(1:30)-1/xi)))