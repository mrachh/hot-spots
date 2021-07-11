function file_id = chunkie_poly(vert_coords)

% Global parameters
MAX_CHUNK_LEN = 1;
file_id = abs(typecast(randi([0 255],1,8,'uint8'),'int64'));
file_name = sprintf('temp/%d.png',file_id);

% Create the polygon

cparams = [];
cparams.eps = 1.0e-5;
pref = []; 
pref.k = 16;

zk = 1.1 + 0.1*1j;

% Create source and target location
src0 = [0.3;0.21];
targ0 = [0.7;1.8];

% Create the chunked geometry
chnkr = chunkerpoly(vert_coords, cparams, pref);


assert(checkadjinfo(chnkr) == 0);
refopts = []; refopts.maxchunklen = MAX_CHUNK_LEN;
chnkr = chnkr.refine(refopts); chnkr = chnkr.sort();

% plot geometry and data

f = figure;
clf
plot(chnkr,'-b')
hold on
quiver(chnkr,'r')
hold on
xlim([-3,3])
ylim([-3,3])
set(gcf, 'PaperPosition', [0.25 2.5 4.0 4.0]);
saveas(gcf,file_name)

end