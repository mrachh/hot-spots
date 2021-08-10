function nothing = gd_plot(gd_log)

    length = sum(~isnan(gd_log.loss));

    if length < 1
        error('Invalid gd_log!')
    end

    iterations = 1:1:length;
    addpath('../src');

    % PLOT 1 loss vs grad
    figure(1);
    clf;
    plot(gd_log.loss);
    hold on;
    plot(gd_log.grad);
    legend('loss', 'grad');
    xticks(iterations);
    title('loss vs grad');
    

    % PLOT 2 objective as a function of the parameter
    figure(2);
    clf;
    scatter(gd_log.weight, gd_log.loss, 'Marker', '+');
    title('weight vs loss');

    % PLOT 3 log 10 grad norm
    figure(3);
    clf;
    plot(log10(gd_log.grad_norm));
    xticks(iterations);
    title('grad norm');



end