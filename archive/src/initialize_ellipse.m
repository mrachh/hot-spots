function rads = initialize_ellipse(rx,ry,cx,cy,n)
    angles = initialize_angles(n);
    cosine = cos(angles);
    sine = sin(angles);
    a = (ry^2)*(cosine.^2)+(rx^2)*(sine.^2);
    b = -(2*cx*(ry^2))*cosine-(2*cy*(rx^2))*sine;
    c = (cx^2)*(ry^2)+(cy^2)*(rx^2)-(rx^2)*(ry^2);
    rads = (-b+(b.^2-(4*c)*a).^(0.5))./(2*a);
end