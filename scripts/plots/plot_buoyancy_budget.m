%  [] = plot_buoyancy_budget(sample, wda, bpe, weights)
% All arguments are passed to calc_buoyancy_budget

function [] = plot_buoyancy_budget(sample, wda, bpe, weights)

    [iso, meanb, meanbslice, int_b0dz0dt] = ...
        calc_buoyancy_budget(sample, wda, bpe, weights);

    sim_info = sample.sim_info;

    hfig = figure;
    ax = packfig(3, 1)
    plot(ax(1), sample.t, sample.b)
    hold(ax(1), 'on')
    hl = plot(ax(1), wda.time, wda.T, 'linewidth', 2)
    hl2 = plot(ax(1), wda.time, wda.T_Jq, 'k', 'linewidth', 2)
    plot(ax(1), [sample.t(1), sample.t(end)], [1, 1]*iso, ...
         '-', 'color', [1, 1, 1]*0.5)
    hl1 = legend(ax(1), '$\chi$-pod sampled buoyancy', ...
                 'mean buoyancy per profile', ...
                 '$J_q^t$ weighted temperature', ...
                 '$b_0$ surface', 'location', 'southeast');
    title(ax(1), ['mean buoyancy budget for isosurface $b_0$ = ' ...
                  num2str(iso, '%.3f')])
    ylabel(ax(1), 'buoyancy')
    ax(1).Title.Interpreter = 'latex';
    hl1.Interpreter = 'latex';

    plot(ax(2), wda.time, wda.Jq)
    ylabel(ax(2), '$$J_q^t$$')
    ax(2).YLabel.Interpreter = 'latex';

    hold(ax(3), 'on')
    plot(ax(3), bpe.time, meanb - meanb(1), 'displayname', 'mean b (full)')
    plot(ax(3), bpe.time, meanb - meanb(1) + int_b0dz0dt, ...
         'displayname', 'mean b (full) + $b_0 \; dz_0/dt$')
    plot(ax(3), bpe.time, meanbslice - meanbslice(1), 'displayname', 'mean b (slice)')
    plot(ax(3), wda.time, ...
         1/sim_info.Pr/sim_info.Re .* cumtrapz(wda.time, repnan(wda.Jq, 0)), ...
         'displayname', '$$\frac{1}{Re Pr} \int J_q^t \; dt$$')
    hl3 = legend(ax(3), '-dynamiclegend');
    hl3.Interpreter = 'latex';
    xlabel(ax(3), 'time')

    labels = 'abc';
    for ii = [1,2,3]
        htxt(ii) = text(ax(ii), 0.025, 0.1, ['(' labels(ii) ')'], ...
                        'units', 'normalized');
    end

    for aa = ax
        axes(aa); beautify([8 9 10]+3, 'Times');
    end
    for aa = ax(1:2)
        aa.XTickLabels = {};
    end

    hl.LineWidth = 2;
    resizeImageForPub('portrait')
    hfig.Position = [680 230 720 748];