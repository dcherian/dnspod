simdir = '../simulation_slices_Re1000Ri012Pr1/';

savedir = [simdir '/samples/'];

mkdir(savedir); % for along-trajectory samples
mkdir([simdir '/means']); % for mean fields

% simulation info from first and last file
fnames = dir([simdir '/slices*.mat']);
first = load([simdir '/' fnames(1).name], 'coords', 'sim_info');

% dimensional parameters
layer.nu = 8e-4;
layer.kappa = layer.nu/first.sim_info.Pr;
% 2h* (m)
layer.width = 10;
% 2u* (m/s) velocity jump
layer.vjmp = 2 * first.sim_info.Re * layer.nu / (layer.width/2);
% 2B* buoyancy jump
layer.Bjmp = first.sim_info.Ri * (layer.vjmp/2)^2 / (layer.width/2);
layer.timescale = layer.width/layer.vjmp;
layer

% sampling parameters
samp.pump_z = 0.75/(layer.width/2); % (m) pumping *vertical amplitude*
samp.pump_period = 10/layer.timescale; % (s) pumping frequency
samp.uback = 0.25/(layer.vjmp/2); % (m/s) background flow that advects
                                  % the shear layer past the chipod
samp.t0 = first.coords.t(1); % save start of trajectory so that I can be
                             % at the right x-position when processing
                             % files in parallel

%% (parallel) loop through files and sample along trajectory
failed = [];
ticstart = tic;
parfor(ff=1:length(fnames), 4)
    disp(['Processing file ' num2str(ff) '/' num2str(length(fnames))]);
    savename = [savedir '/sample_' num2str(ff, '%02d') '.mat'];
    filename = [simdir '/' fnames(ff).name];

    try
        sample_single_file(filename, savename, simdir, ff, layer, samp);
    catch ME
        failed = [failed ff]
        disp(ME);
    end
end
disp('Finished processing files.')
disp('Failed = ')
disp(failed)
toc(ticstart);

%% once sampled, combine and save to savedir/merged.mat
% merge 'means' properly and save that to simulation directory
ticstart = tic;

sample = merge_mat_files(savedir, '/sample*.mat', 0, 2);
sample.samp = samp;
sample.layer = layer;
sample.moor.dzm = sample.moor.dzm(:, 1);
sample.sim_info = first.sim_info;
sample.coords = first.coords;
assert(all(diff(sample.t) > 0))
save([savedir '/merged.mat'], 'sample')

bpe = merge_mat_files([simdir '/bpe/'], 'bpe_*.mat', 0, 2);
bpe = bpe.bpe;
bpe.binval= bpe.binval(1:1000); % time-invariant
bpe.sim_info = first.sim_info;
bpe.coords = first.coords;
% make sure time is monotonic
assert(all(diff(bpe.time) > 0))
% make sure I can recover bpe.bpe
for tt=1:size(bpe.Z, 2)
    bpenew(tt) = -bpe.sim_info.Ri * ...
        trapz(bpe.Z(:,tt), bpe.binval .* bpe.Z(:,tt), 1) ...
        / trapz(diff(bpe.Z(:, tt)));
end
assert(all((bpenew - bpe.bpe) < 1e-5))
save([simdir '/bpe.mat'], 'bpe')

means = merge_mat_files([simdir '/means/'], 'means_*.mat', 0, 2);
means.sim_info = first.sim_info;
means.coords = first.coords;
means.time = bpe.time;
save([simdir '/means.mat'], 'means')

disp('Finished merging files');
toc(ticstart);

%% Process WDA estimate
[sample, wda] = process_sampled_field(savedir, 90);
hax = plot_estimate(wda);
plot(hax(2), wda.time, wda.Tzi)

%% compare gradients
CreateFigure; hold on;
plot(sample.moor.t(1:50:end), sample.moor.Tzm(1:20, 1:50:end), ...
     '-', 'color', [1,1,1]*0.75, 'handlevisibility', 'off');
plot(wda.time, wda.dTdz, 'r-', 'linewidth', 2, 'displayname', 'sorted');
plot(wda.time, wda.Tzi, 'k-', 'linewidth', 2, 'displayname', 'internal');
legend('-dynamiclegend');
liney(0);
title({'comparing sorted,internal gradient '; ...
       'against range of "mooring gradients."'});
ylabel('db/dz'); xlabel('time')

export_fig('images/compare-dbdz.png')

% pcolorcen(slices.eps(:,:,1)');
% hold on;
% scatter(traj.x, traj.z, 64, sample, 'filled', 'markeredgecolor', 'w')
% sample = sample_along_trajectory(slices, traj)

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
