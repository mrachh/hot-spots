test_pgon = nsidedpoly(5);
verts = nsidedpoly(5).Vertices';
flipped = flipud(verts')';
fprintf('err: %5.2e\n', norm(preproc_verts(flipped) - verts))