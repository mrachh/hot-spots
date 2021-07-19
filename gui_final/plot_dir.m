function [h] = plot_dir(chnk_plot_axis, uscat, direction, zk, targets, out, xxtarg, yytarg, plot_option, imre)
    disp(plot_option)

    addpath('../src');
    kvec = zk .* [cos(direction); sin(direction)];
    uin = planewave(kvec,targets(:,out));
    utot = uscat(:)+uin(:);
    
    %
    
    maxin = max(abs(uin(:)));
    maxsc = max(abs(uin(:)));
    maxtot = max(abs(uin(:)));
    
    maxu = max(max(maxin,maxsc),maxtot);

    zztarg = nan(size(xxtarg)) + 1i * nan(size(xxtarg)) ;

    if strcmp(plot_option, 'incoming field')
        zztarg(out) = uin;
    elseif strcmp(plot_option, 'scattered field')
        zztarg(out) = uscat;
    else
        zztarg(out) = utot;
    end

    if strcmp(imre,'real')
        zztarg_plot = real(zztarg);
    else
        zztarg_plot = imag(zztarg);
    end

    h = pcolor(chnk_plot_axis ,xxtarg,yytarg,zztarg_plot);
    set(h,'EdgeColor','none');
    colormap(chnk_plot_axis);
    caxis([-maxu,maxu]);
    set(gcf,'Visible', 'off');
    axis(chnk_plot_axis, [-3 3 -3 3]);
    
end