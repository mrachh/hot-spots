test_pgon = nsidedpoly(5);
verts = nsidedpoly(5).Vertices';
flipped = flipud(verts')';
verts
flippedflippedverts = preproc_verts(flipped)
disp('works up to some permutation')