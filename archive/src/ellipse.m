function [r,d,d2] = ellipse(t,a,b,ctr)
 if nargin < 4
    ctr = zeros(2,1);
 end
 x0 = ctr(1);
 y0 = ctr(2);
 ct = cos(t);
 st = sin(t);
 xs = x0 + a*ct;
 ys = y0 + b*st;
 dxs = -a*st;
 dys = b*ct;
 d2xs = -a*ct;
 d2ys = -b*st;
 r = [(xs(:)).'; (ys(:)).'];
 d = [(dxs(:)).'; (dys(:)).'];
 d2 = [(d2xs(:)).'; (d2ys(:)).'];  

end