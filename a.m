% series sum
addpath('~/matlab_packages/bessel_zero');
xi = besselzero(1,1);
res = 0;
for i = 1:100
    res = res + besselj(i+1, xi)/(2*besselj(i, xi));
end