function [hs,chnkr,clmparams] = load_geom(uiax)

hs = [];

% obtain physical and geometric parameters
icase = 6;
clmparams = clm.setup(icase);

if isfield(clmparams,'k')
  k = clmparams.k;
end
if isfield(clmparams,'coef')
  coef = clmparams.coef;
end
if isfield(clmparams,'cpars')
  cpars = clmparams.cpars;
end
if isfield(clmparams,'cparams')
  cparams = clmparams.cparams;
end
if isfield(clmparams,'ncurve')
  ncurve = clmparams.ncurve;
end
if isfield(clmparams,'ndomain')
  ndomain = clmparams.ndomain;
end

vert = [];
if isfield(clmparams,'vert')
  vert = clmparams.vert;
end

if isfield(clmparams, 'nch')
  nch = clmparams.nch;
end

if isfield(clmparams, 'src')
  src = clmparams.src;
end

chnkr(1,ncurve) = chunker();

% define functions for curves
fcurve = cell(1,ncurve);
for icurve=1:ncurve
  fcurve{icurve} = @(t) clm.funcurve(t,icurve,cpars{icurve},icase);
end

% number of Gauss-Legendre nodes on each chunk
ngl = 16;

pref = []; 
pref.k = ngl;
disp(['Total number of unknowns = ',num2str(sum(nch)*ngl*2)])

% discretize the boundary
start = tic; 

for icurve=1:ncurve
  chnkr(icurve) = chunkerfuncuni(fcurve{icurve},nch(icurve),cparams{icurve},pref);
end


t1 = toc(start);

[chnkr,clmparams] = clm.get_geom_gui(icase);

%fprintf('%5.2e s : time to build geo\n',t1)

% plot geometry
%fontsize = 20;
%figure(1)
%clf
hold(uiax,'on')
h = plot_new(uiax,chnkr,'r-','LineWidth',2);
hs = [hs,h];

hold(uiax,'on')
if ~isempty(vert)
  h2 = plot(uiax,vert(1,:),vert(2,:),'k.','MarkerSize',20);
  hs = [hs,h2];
end

%axis equal
%title('Boundary curves','Interpreter','LaTeX','FontSize',fontsize)
%xlabel('$x_1$','Interpreter','LaTeX','FontSize',fontsize)
%ylabel('$x_2$','Interpreter','LaTeX','FontSize',fontsize)
%drawnow
% figure(2)
% clf
% quiver(chnkr)
% axis equal

end

