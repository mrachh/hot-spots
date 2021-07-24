function [xang,yang,wtot] = get_chunkie_quads(chnkr,k,xy_s)


opts = struct();
% k = 16;
[x,w,u,v] = lege.exps(k,opts);

xr = (x+1)/2;
wr = w/2;


cshape = size(chnkr.r);
rs     = reshape(chnkr.r,[cshape(1),cshape(2)*cshape(3)]);
xs     = (rs(1,:)-xy_s(1));
ys     = (rs(2,:)-xy_s(2));
rtot = sqrt(xs.^2+ys.^2);
ws     = weights(chnkr);
ws     = ws(:)';

%%% produce the quadrature points
[xrad,xang] = meshgrid(xr,xs);
[xrad,yang] = meshgrid(xr,ys);

xang = xang.*xrad+xy_s(1);
yang = yang.*xrad+xy_s(2);

xang = xang(:);
yang = yang(:);


%%% now, produce the weights (scaled appropriately)
[wrad,wang] = meshgrid(wr,ws);
wtot = wrad.*wang;
wtot = wtot(:);
rang = sqrt((xang-xy_s(1)).^2 + (yang-xy_s(2)).^2);
wtot = wtot.*rang;

dr = reshape(chnkr.d,[cshape(1),cshape(2)*cshape(3)]);
drx= dr(1,:);
drx= drx(:);
dry= dr(2,:);
dry= dry(:);
drt= sqrt(drx.^2 + dry.^2);
dcurve = dry.*(xs(:))-drx.*(ys(:));
dcurve = dcurve./drt./rtot(:);

[~,dwcurve] = meshgrid(wr,dcurve);
dwcurve = dwcurve(:);

wtot = dwcurve.*wtot;

xang = xang(:);
yang = yang(:);
wtot = wtot(:);

end

