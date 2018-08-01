function [] = plot_jq(savedir, dt)

    [sample, wda] = process_sampled_field(savedir, dt);

    figure;
    pcolorcen(wda.tmat, wda.Tcen, wda.Jmat)
    caxis([prctile(wda.Jmat(:), 2), ...
           prctile(wda.Jmat(:), 98)])
    colormap(bone)
    liney(nanmean(-wda.T_Jq))
    title(num2str([dt nanmean(-wda.T_Jq)]))
end