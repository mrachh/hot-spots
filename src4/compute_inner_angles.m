function inner_angles = compute_inner_angles(angles, rads)
    n = length(rads);
    triangles = zeros(2,n-1);
    inner_angles = zeros(1,n);
    for i = 1:n-1
        theta = angles(i+1) - angles(i);
        cos_theta = cos(theta);
        r1 = rads(i);
        r2 = rads(i+1);
        r = sqrt(r1^2+r2^2-2*r1*r2*cos_theta);
        cos_theta1 = (r1^2+r^2-r2^2)/(2*r1*r);
        cos_theta2 = (r2^2+r^2-r1^2)/(2*r2*r);
        theta1 = acos(cos_theta1);
        theta2 = acos(cos_theta2);
        triangles(1,i) = theta1;
        triangles(2,i) = theta2;
    end
    inner_angles(1) = triangles(1,1);
    inner_angles(n) = triangles(2,n-1);
    for i = 2:n-1
        inner_angles(i) = triangles(2,i-1)+triangles(1,i);
    end
end