clear;clc;addpath('../src');

figid = 0


% figid = figid + 1;
% rs = ones(1,5)/sqrt(pi/2);
% chnkr = chnk_poly(rs);
% figure(figid);
% plot(chnkr);
% isconvex = check_convex(rs);
% if isconvex
%     title('Is convex');
% else
%     title('is not convex');
% end



% figid = figid + 1;
% rs = [1 0.5 1 1 1]
% chnkr = chnk_poly(rs);
% figure(figid);
% plot(chnkr);
% isconvex = check_convex(rs);
% if isconvex
%     title('Is convex');
% else
%     title('is not convex');
% end

% % error()

% figid = figid + 1;
% rs = [1 1 0.5]
% chnkr = chnk_poly(rs);
% figure(figid);
% plot(chnkr);
% isconvex = check_convex(rs);
% if isconvex
%     title('Is convex');
% else
%     title('is not convex');
% end


% figid = figid + 1;
% rs = [1 1 1 0.9]
% chnkr = chnk_poly(rs);
% figure(figid);
% plot(chnkr);
% isconvex = check_convex(rs);
% if isconvex
%     title('Is convex');
% else
%     title('is not convex');
% end


% figid = figid + 1;
% rs = [1 1.1 1.2 1]
% chnkr = chnk_poly(rs);
% figure(figid);
% plot(chnkr);
% isconvex = check_convex(rs);
% if isconvex
%     title('Is convex');
% else
%     title('is not convex');
% end

figid = figid + 1;
rs = [1 0.1 1.2 1 1]
chnkr = chnk_poly(rs);
figure(figid);
clf;
plot(chnkr);
[isconvex, rs_conv] = check_convex(rs);
hold on
plot(chnk_poly(rs_conv))
legend('rs', 'rs_conv')
if isconvex
    title('Is convex');
else
    title('is not convex');
end