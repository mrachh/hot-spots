function [] = plot_chunker(chnkr)
    clf
    plot(chnkr,'-b')
    hold on
    quiver(chnkr,'r')
    axis equal
end