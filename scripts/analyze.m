simdir = '../simulation_slices_Re1000Ri012Pr1/';
savedir = [simdir '/samples/'];

load([simdir '/bpe.mat'])
load([savedir '/merged.mat'])

%% attempt to calculate heat flux budget for mean isosurface

[sample, wda] = process_sampled_field(savedir, 90);
plot_buoyancy_budget()

export_fig images/buoyancy-budget.pdf

%% sensitivity to wda.dt

CreateFigure;
ax(1) = subplot(211); hold on;
ax(2) = subplot(212); hold on;
for tt = [30 ,60, 90, 120, 150, 180, 210, 240]
    [sample, wda] = process_sampled_field(savedir, tt);

    plot(ax(1), wda.time, wda.Jq, 'DisplayName', num2str(tt))
    plot(ax(2), wda.time, cumtrapz(wda.time, repnan(wda.Jq, 0)), ...
         'DisplayName', num2str(tt))
end

hl = legend(ax(1), '-dynamiclegend');
hl.Location = 'SouthEast';

ax(1).Title.String = {'sensitivity of Jq timeseries to chunking time. ';  ...
                    ' Values in dimensional (s)'}
ax(1).YLabel.String = '$$J_q^t$$';
ax(1).YLabel.Interpreter = 'latex';
ax(2).YLabel.String = '$$\int J_q^t dt $$';
ax(2).YLabel.Interpreter = 'latex';
axes(ax(1)); beautify([10, 11, 12]+2)
axes(ax(2)); beautify([10, 11, 12]+2)

resizeImageForPub('portrait')
export_fig images/jq-wda-dt-sensitivity.png