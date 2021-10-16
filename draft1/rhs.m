function res = rhs(y,z)

    xi1 = 3.831705970207512;

    j1prime = (besselj(0,xi1)-besselj(2,xi1))/2;

    res1 = (pi/4)*z*(bessely(1,z*y) - besselj(1, z*y)*bessely(1,z)/besselj(1,y));

    res2 = xi1*besselj(1,xi1*y)/((z^2-xi1^2)*j1prime^2);

    res = res1 - res2;



end