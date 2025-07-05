function rads = initialize_parabola(n)
    angles = (0:(n-1)).*(pi/(n-1));
    horizontal_shift = 0.1;
    si = sin(angles);
    co = cos(angles);
    a = co.^2;
    b = si-(2*horizontal_shift).*co;
    c = ones(size(angles)).*(horizontal_shift^2-1);
    rads = (-b+sqrt(b.^2-4*(a.*c)))./(2*a);
end