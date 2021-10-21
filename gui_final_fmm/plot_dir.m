function [h] = plot_dir(chnk_plot_axis, uscat, direction, zk, targets, ...
                out0, xxtarg, yytarg, plot_option, imre)
    disp(plot_option)

    addpath('../src');
    kvec = zk .* [cos(direction); sin(direction)];
    uin = planewave(kvec,targets(:,out0));
    utot = uscat(:)+uin(:);
    
    %
    
    maxin = max(abs(uin(:)));
    maxsc = max(abs(uin(:)));
    maxtot = max(abs(uin(:)));
    
    maxu = max(max(maxin,maxsc),maxtot);
    minu = -maxu;
    
    zztarg = nan(size(xxtarg)) + 1i * nan(size(xxtarg)) ;

    if strcmp(plot_option, 'incoming field')
        disp('inside incoming field')
        zztarg(out0) = uin;
    elseif strcmp(plot_option, 'scattered field')
        disp('inside scattered field')
        zztarg(out0) = uscat;
    else
        disp('inside total field')
        zztarg(out0) = utot;
    end

    if strcmp(imre,'real')
        zztarg_plot = real(zztarg);
    elseif (strcmp(imre,'imaginary'))
        zztarg_plot = imag(zztarg);
    else
        zztarg_plot = abs(zztarg);    
    end
    maxu = max(zztarg_plot(:));
    minu = min(zztarg_plot(:));
        

    h = pcolor(chnk_plot_axis ,xxtarg,yytarg,zztarg_plot);
    set(h,'EdgeColor','none');
    colormap(chnk_plot_axis);
    caxis([minu,maxu]);
    set(gcf,'Visible', 'off');
    axis(chnk_plot_axis, [-3 3 -3 3]);
    colorbar(chnk_plot_axis);
    
end
