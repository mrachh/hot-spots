clear;clc;addpath('../src');

figid = 0


figid = figid + 1;
rs = ones(1,5)/sqrt(pi/2);
valid_vert_idx = [1 1 1 0 1];
chnkr = chnk_polyeven(rs,valid_vert_idx);
figure(figid);
plot(chnkr);
isconvex = check_convex(rs,'even',valid_vert_idx);
if isconvex
    title('Is convex');
else
    title('is not convex');
end



figid = figid + 1;
rs = [1 0.5 1 1 1]
valid_vert_idx = [1 1 0 1 1];
chnkr = chnk_polyeven(rs,valid_vert_idx);
figure(figid);
plot(chnkr);
isconvex = check_convex(rs,'even',valid_vert_idx);
if isconvex
    title('Is convex');
else
    title('is not convex');
end

% error()

figid = figid + 1;
rs = [1 1 0.5]
valid_vert_idx = [1 1 1];
chnkr = chnk_polyeven(rs,valid_vert_idx);
figure(figid);
plot(chnkr);
isconvex = check_convex(rs,'even',valid_vert_idx);
if isconvex
    title('Is convex');
else
    title('is not convex');
end


figid = figid + 1;
rs = [1 1 1 0.9]
valid_vert_idx = [1 1 1 1];
chnkr = chnk_polyeven(rs,valid_vert_idx);
figure(figid);
plot(chnkr);
isconvex = check_convex(rs,'even',valid_vert_idx);
if isconvex
    title('Is convex');
else
    title('is not convex');
end

figid = figid + 1;
rs = [1 1 1 -1]
valid_vert_idx = [1 1 1 1];
chnkr = chnk_polyeven(rs,valid_vert_idx);
figure(figid);
plot(chnkr);
isconvex = check_convex(rs,'even',valid_vert_idx);
if isconvex
    title('Is convex');
else
    title('is not convex');
end

figid = figid + 1;
rs = [1 1.1 1.2 1]
valid_vert_idx = [1 1 1 1];
chnkr = chnk_polyeven(rs,valid_vert_idx);
figure(figid);
plot(chnkr);
isconvex = check_convex(rs,'full',valid_vert_idx);
if isconvex
    title('Is convex');
else
    title('is not convex');
end

figid = figid + 1;
rs = [1 0.5 1.2 1]
valid_vert_idx = [1 1 1 1];
chnkr = chnk_polyeven(rs,valid_vert_idx);
figure(figid);
plot(chnkr);
isconvex = check_convex(rs,'full',valid_vert_idx);
if isconvex
    title('Is convex');
else
    title('is not convex');
end