addpath(genpath('./'))

sampname = 'pod-01'
simdir = '../slices/simulation_slices_Re1000Ri012Pr1/';
savedir = [simdir '/samples/' sampname '/'];

load([simdir '/bpe.mat'])
load([savedir '/merged.mat'])

sim_info = sample.sim_info;

%% attempt to calculate heat flux budget for mean isosurface

[sample, wda] = process_sampled_field(savedir, 90);
plot_buoyancy_budget(sample, wda, bpe, 'Jq')

export_fig images/buoyancy-budget.pdf

%% subsample Jmat at iso-surface level

mask = ~isnan(wda.Tcen(:));
J = scatteredInterpolant([wda.tmat(mask), wda.Tcen(mask)], wda.Jmat(mask));
figure; plot(wda.time, 1/1000 * ...
             cumtrapz(wda.time, J(wda.time, 0.01*ones(size(wda.time)))))



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
        calc_buoyancy_budget(sample, wda, bpe, 'Jq');
hplt = plot(ax(2), bpe.time, meanb - meanb(1) + int_b0dz0dt, ...
            'displayname', 'mean b (full) + $b_0 \; dz_0/dt$', ...
            'color', 'k', 'linewidth', 2)
legend(hplt, 'LHS(buoyancy budget)')

axes(ax(1)); beautify([10, 11, 12]+2, 'Times')
axes(ax(2)); beautify([10, 11, 12]+2, 'Times')
resizeImageForPub('portrait')
hfig.Position = [100 421 720 577];

export_fig images/jq-wda-dt-sensitivity.pdf


%% compare gradients
CreateFigure; hold on;
plot(sample.moor.t(1:50:end), sample.moor.Tzm(1:20, 1:50:end), ...
     '-', 'color', [1,1,1]*0.75, 'handlevisibility', 'off');
plot(wda.time, wda.dTdz, 'r-', 'linewidth', 2, 'displayname', 'sorted \chipod');
plot(wda.time, wda.Tzi, 'k-', 'linewidth', 2, 'displayname', 'internal');

% this gives a characteristic shear layer thickness -
% note h* is the shear layer half-width,
% so initial thickness is 2 in nondimensional units
I_th = trapz(means.coords.z, 1-(means.b).^2)/2;
% this should give an overall stratification over the shear layer,
% i.e. delta(B)/delta(z)~(2B0*)/(2h*)
N_b = sqrt(1./I_th);
plot(means.time, N_b, 'b-', 'displayname', 'Mean gradient across shear layer');
plot(means.time([1, 9000]), [1, 1] * nanmean(wda.dTdz), 'r--', ...
     'displayname', 'mean(sorted)')

legend('-dynamiclegend');
liney(0);
title({'comparing sorted,internal gradient '; ...
       'against range of "mooring gradients."'});
ylabel('db/dz'); xlabel('time')

export_fig('images/compare-dbdz.png')

%% estimate mean <wb> over volume sampled by chipod

iz0 = find_approx(means.coords.z, min(sample.traj.z));
iz1 = find_approx(means.coords.z, max(sample.traj.z));

% average (in z) of x,y-averaged wb
wb = trapz(means.coords.z(iz0:iz1)', means.bw(iz0:iz1, :), 1)/ ...
     diff(means.coords.z([iz1, iz0]));
plot(means.time, wb); liney(mean(wb)); liney(0)

% pcolorcen(slices.eps(:,:,1)');
% hold on;
% scatter(traj.x, traj.z, 64, sample, 'filled', 'markeredgecolor', 'w')
% sample = sample_along_trajectory(slices, traj)


%% process ΔBPE for trajectory
% not sure how to do this in a consistent manner given overturns

load([simdir '/bpe.mat'])
load([savedir '/merged.mat'])

bpenew = nan([1, size(bpe.Z, 2)]);
for tt=1:length(bpenew)
    zrange = [find_approx(bpe.Z(:, tt)-12.5, min(sample.traj.z)): ...
              find_approx(bpe.Z(:, tt)-12.5, max(sample.traj.z))];

    bpenew(tt) = -bpe.sim_info.Ri * ...
        trapz(bpe.Z(zrange,tt), bpe.binval(zrange) .* bpe.Z(zrange,tt), 1) ...
        / trapz(diff(bpe.Z(zrange, tt)));
end
plot(bpenew);

%% check trajectory wrapping
tt = 500;
hdl = plot(sample.traj.x(tt-199:tt), sample.traj.z(tt-199:tt));
xlim([0 (sample.sim_info.LX * layer.width/2)])
for tt = tt:length(sample.traj.t)
   hdl.XData = sample.traj.x(tt-400:tt);
   hdl.YData = sample.traj.z(tt-400:tt);
   pause(0.1);
end

%% debugging stuff
% last = load([simdir '/' fnames(2).name], 'sim_info', 'coords');

% test plot
% figure;
% subplot(2,1,1);
% pcolorcen(dim.x, dim.z, slices.eps(:,:,1)');
% hold on;
% plot(traj.x, traj.z, 'w')
% subplot(2,1,2);
% pcolorcen(dim.x, dim.z, slices.eps(:,:,end)');
% hold on;
% plot(traj.x, traj.z, 'w')

% plot3(traj.x, traj.z, traj.t);
% xlabel('x'); ylabel('z'); zlabel('t')
