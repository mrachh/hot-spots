function res = semicirc_eig(xycoord)
    x = xycoord(1);
    y = xycoord(2);
    r = sqrt(x^2 + y^2);
    theta = atan2(y, x);
    zk = 3.8317059702075123156;
    res = besselj(1, zk * r)* sin(theta);
end