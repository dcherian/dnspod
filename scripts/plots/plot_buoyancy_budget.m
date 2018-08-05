%  [] = plot_buoyancy_budget(sample, wda, bpe, weights)
% All arguments are passed to calc_buoyancy_budget

function [] = plot_buoyancy_budget(sample, wda, bpe, iso)

    [totalb, totalbslice, b0z0] = ...
        calc_buoyancy_budget(sample, wda, bpe, iso);

    RePr = sample.sim_info.Re * sample.sim_info.Pr;

    hfig = figure;
    ax = packfig(3, 1);
    hold(ax(1), 'on')
    hold(ax(2), 'on')
    hold(ax(3), 'on')

    plot(ax(1), sample.t, sample.b)
    hl = plot(ax(1), wda.time, wda.T, 'linewidth', 2);
    hl2 = plot(ax(1), wda.time, wda.T_Jq, 'k', 'linewidth', 2)
    plot(ax(1), [sample.t(1), sample.t(end)], [1, 1]*iso, ...
         '-', 'color', [1, 1, 1]*0.5)
    hl1 = legend(ax(1), '$\chi$-pod sampled buoyancy', ...
                 'mean buoyancy per profile', ...
                 '$J_q^t$ weighted temperature', ...
                 '$b_0$ surface', 'location', 'southeast');
    title(ax(1), [wda.name ' | mean buoyancy budget for isosurface $b_0$ = ' ...
                  num2str(iso, '%.3f')])
    ylabel(ax(1), 'buoyancy')
    ax(1).Title.Interpreter = 'latex';
    hl1.Interpreter = 'latex';

    totalbi = interp1(sample.t, totalb, wda.time);
    plot_flux(ax, RePr, wda.time, wda.Jq, 'mean')
    plot_flux(ax, RePr, wda.time, interpolate_Jq_to_iso(wda, iso), 'interp')
    plot(ax(2), avg1(sample.t), diff(totalb)./diff(sample.t), ...
         'displayname', '$$db/dt$$')
    hl2 = legend(ax(2), '-dynamiclegend', 'location', 'southeast')
    hl2.Interpreter = 'latex';
    ax(2).YLabel.Interpreter = 'latex';

    plot(ax(3), bpe.time, totalb - totalb(1), 'displayname', 'mean b (full)')
    plot(ax(3), bpe.time, totalb - totalb(1) + (b0z0 - b0z0(1)), ...
         'displayname', 'mean b (full) + $b_0 \; z_0$')
    plot(ax(3), bpe.time, totalbslice - totalbslice(1), ...
         'displayname', 'mean b (slice)')
    hl3 = legend(ax(3), '-dynamiclegend', 'location', 'southwest');
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

end

function [] = plot_flux(ax, RePr, time, Jq, name)

    Jq = repnan(Jq, 0);
    name = ['$$1/RePr J_q^t$$: ' name];
    hl = plot(ax(2), time, 1/RePr * Jq, 'displayname', name)
    plot(ax(3), time, 1/RePr * cumtrapz(time, Jq), ...
         'displayname', ['$$\int$$' name], 'color', hl.Color)

end