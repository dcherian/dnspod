addpath(genpath('./'))

% name simulation
simdir = '../slices/simulation_slices_Re1000Ri012Pr1/';
sim_info.Re = 1000;
sim_info.Pr = 1;
sim_info.Ri = 0.12;

% dimensional parameters
layer.nu = 8e-4;
layer.kappa = layer.nu/sim_info.Pr;
% 2h* (m)
layer.width = 10;
% 2u* (m/s) velocity jump
layer.vjmp = 2 * sim_info.Re * layer.nu / (layer.width/2);
% 2B* buoyancy jump
layer.Bjmp = sim_info.Ri * (layer.vjmp/2)^2 / (layer.width/2);
layer.timescale = layer.width/layer.vjmp;
layer

% sampling parameters
samp.name = '01'; % unique name for particular subsample
samp.pump_z = 0.75/(layer.width/2); % (m) pumping *vertical amplitude*
samp.pump_period = 10/layer.timescale; % (s) pumping frequency
samp.uback = 0.25/(layer.vjmp/2); % (m/s) background flow that advects
                                  % the shear layer past the chipod
samp

%% actually process
process_output(simdir, layer, samp);

%% once processed, do sorted KT, Jq estimate
[sample, wda] = process_sampled_field(simdir, samp.name, 90)

%% try a buoyancy budget for an isosurface

if ~exist('bpe', 'var'), load([simdir '/bpe.mat']); end

trange = get_turb_time_range(sample);
t0 = find_approx(wda.time, sample.t(trange(1)));
isos = [get_buoy_range(sample.b(trange)), ...
        nanmean(wda.T_Jq(t0:end))];

plot_buoyancy_budget(sample, pod1, bpe, isos)

%% error in estimating separation between isotherms
figure;
plot(wda.time, wda.dz_rmse);
ylabel('RMSE \Delta z')
xlabel('time')

%% Jq as function of time, isosurface
figure;
ax(1) = subplot(211); hold on;
plot_jq(ax(1), wda)
hl(1) = plot(xlim, nanmean(wda.T_Jq)*[1,1], 'k');
hl(2) = plot(xlim, nanmean(sample.b)*[1,1], 'k--');
legend(hl, 'J_q weighted T', 'mean sampled buoyancy')
% beautify([10 11 12]+2, 'Times')

ax(2) = subplot(212);
hold on;
plot(wda.time, wda.Jq)
for iso = [nanmean(wda.T_Jq), nanmean(sample.b)]
    plot(wda.time, repnan(interpolate_Jq_to_iso(wda, iso), 0), 'k')
end
legend(ax(2), 'depth-averaged J_q', 'J_q(J_q weighted b)', 'J_q(mean sample.b)', ...
       'location', 'southeast')
ylabel('$$J_q^t$$', 'interpreter', 'latex')
linkaxes(ax, 'x')