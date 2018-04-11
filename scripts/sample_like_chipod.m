simdir = '../simulation_slices_Re1000Ri012Pr1/';

savedir = [simdir '/samples/'];

mkdir(savedir); % for along-trajectory samples
mkdir([simdir '/bg']); % for background info

% simulation info from first and last file
fnames = dir([simdir '/slices*.mat']);
first = load([simdir '/' fnames(1).name]);

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
samp.pump_z = 2; % (m) pumping vertical amplitude
samp.pump_period = 5; % (s) pumping frequency
samp.uback = 0.25; % (m/s) background flow that advects
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

sample = merge_mat_files(savedir, '/sample*.mat');
sample.samp = samp;
sample.layer = layer;
sample.sim_info = first.sim_info;
sample.coords = first.coords;
save([savedir '/merged.mat'], 'sample')

bg.bpe = merge_mat_files([simdir '/bpe/'], 'bpe_*.mat', 0, 2);
bg.bpe = bg.bpe.bpe;
bp.bpe.binval= bg.bpe.binval(1:1000);
bg.means = merge_mat_files([simdir '/bg/'], 'means_*.mat', 0, 2);
bg.sim_info = first.sim_info;
bg.coords = first.coords;
save([simdir '/bg.mat'], 'bg')

disp('Finished merging files');
toc(ticstart);

%% Process WDA estimate
[sample, wda] = process_sampled_field(savedir);

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
