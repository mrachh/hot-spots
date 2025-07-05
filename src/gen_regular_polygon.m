clear;
startup;
close all;

pi = atan(double(1))*4;
n = 32;
theta = 2*pi/n;
verts = zeros(2,n);
rads = zeros(1,n);
angles = zeros(1,n);

for i = 1:n
    angle = -pi/2+theta/2+(i-1)*theta;
    verts(1,i) = cos(angle);
    verts(2,i) = sin(angle)+cos(theta/2);
    rads(1,i) = norm([verts(1,i) verts(2,i)]);
end

for i = 1:n
    angles(1,i) = pi/(n-1)*(i-1);
end