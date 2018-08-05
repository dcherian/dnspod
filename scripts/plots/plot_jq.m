function [] = plot_jq(ax, wda)

    sizevec = abs(wda.Jmat(:))/nanmax(abs(wda.Jmat(:)))*12 + 10;

    hdots = scatter(ax, wda.tmat(:), wda.Tcen(:), ...
                    sizevec.^2, wda.Jmat(:), 'filled');
    hdots.MarkerEdgeColor = [1,1,1]*0;
    hdots.MarkerEdgeAlpha = 0.5;
    hdots.MarkerFaceAlpha = 0.9;

    % colormap(flip(cbrewer('seq', 'Blues', 32)))
    colormap(flip(lbmap))
    caxis([prctile(wda.Jmat(:), 2), prctile(wda.Jmat(:), 98)]);
    colorbar('southoutside')

    title(ax, [wda.name ' | $$J_q^t$$'], 'interpreter', 'latex')
    hold on
    xlabel(ax, 'time')
    ylabel(ax, 'buoyancy')
end