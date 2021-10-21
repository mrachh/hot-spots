clear;clc;addpath('../src');

x = 0.2;
y = 0.5;
h = 1e-4;
zk = 3.8317059702075123156;

xdd = (semicirc_eig([x+h y])-2*semicirc_eig([x y])+semicirc_eig([x-h y]))/(h^2);
ydd = (semicirc_eig([x y+h])-2*semicirc_eig([x y])+semicirc_eig([x y-h]))/(h^2);
xylap = xdd + ydd;
err = zk^2 * semicirc_eig([x y]) + xylap;



h = 1e-8;
x = 0;
y = 0;

yd = (semicirc_eig([x y+h]) - semicirc_eig([x y]))/h;

h = h/2
yd = (semicirc_eig([x y+h]) - semicirc_eig([x y]))/(h);

h = h/2
yd = (semicirc_eig([x y+h]) - semicirc_eig([x y]))/(h);