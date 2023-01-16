function [] = plot_chnkr(chnkr)
    clf
    plot(chnkr,'-b')
    hold on
    quiver(chnkr,'r')
    axis equal
end