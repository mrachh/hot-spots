n = 16
ycenter = 0.98

th = linspace(0, 2*pi, 400);
xc = cos(th);
yc = sin(th) + ycenter;

[init_rads, angles] = initialize_circle(n, ycenter);
verts = [init_rads .* cos(angles); init_rads .* sin(angles)];
figure; hold on; axis equal;
plot(xc, yc, 'k-', 'LineWidth', 1.5);
for k = 1:n
    plot([0 verts(1,k)], [0 verts(2,k)], 'b--');
end
plot(verts(1,:), verts(2,:), 'ro', 'MarkerFaceColor', 'r');
xlabel('x'); ylabel('y');
title(sprintf('Circle center (0,%.2f), n=%d', ycenter, n));
legend('circle','rays','vertices','Location','best');