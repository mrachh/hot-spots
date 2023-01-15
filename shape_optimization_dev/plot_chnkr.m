function [] = plot_chnkr(chnkr)

    figure(1)
    clf
    plot(chnkr,'-b')
    hold on
    quiver(chnkr,'r')
    axis equal
end