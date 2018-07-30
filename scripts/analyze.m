simdir = '../simulation_slices_Re1000Ri012Pr1/';
savedir = [simdir '/samples/'];

load([simdir '/bpe.mat'])
load([savedir '/merged.mat'])

%% attempt to calculate heat flux budget for mean isosurface

[sample, wda] = process_sampled_field(savedir, 90);
plot_buoyancy_budget(sample, wda, bpe, 'sample')

export_fig images/buoyancy-budget.pdf

%% sensitivity to wda.dt

hfig = CreateFigure;
ax = packfig(2, 1)
hold(ax(1), 'on')
hold(ax(2), 'on')

for tt = [30 ,60, 90, 120, 150, 180, 210, 240]
    [sample, wda] = process_sampled_field(savedir, tt);

    plot(ax(1), wda.time, wda.Jq, ...
         'DisplayName', num2str(tt))
    plot(ax(2), wda.time, ...
         1/sim_info.Pr/sim_info.Re .* cumtrapz(wda.time, repnan(wda.Jq, 0)), ...
         'DisplayName', num2str(tt))
end

hl = legend(ax(1), '-dynamiclegend');
hl.Location = 'SouthEast';

ax(1).Title.String = {'sensitivity of Jq timeseries to chunking time. ';  ...
                    ' Values in dimensional (s)'}
ax(1).YLabel.String = '$$J_q^t$$';
ax(1).YLabel.Interpreter = 'latex';
ax(2).YLabel.String = '$$\frac{1}{Re Pr}\int J_q^t dt $$';
ax(2).YLabel.Interpreter = 'latex';

[iso, meanb, meanbslice, int_b0dz0dt] = ...
        calc_buoyancy_budget(sample, wda, bpe, weights);
hplt = plot(ax(2), bpe.time, meanb - meanb(1) + int_b0dz0dt, ...
            'displayname', 'mean b (full) + $b_0 \; dz_0/dt$', ...
            'color', 'k', 'linewidth', 2)
legend(hplt, 'LHS(buoyancy budget)')

axes(ax(1)); beautify([10, 11, 12]+2, 'Times')
axes(ax(2)); beautify([10, 11, 12]+2, 'Times')
resizeImageForPub('portrait')
hfig.Position = [100 421 720 577];

export_fig images/jq-wda-dt-sensitivity.pdf