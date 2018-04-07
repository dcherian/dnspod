dirname = '../simulation_slices_Re1000Ri012Pr1/';

savedir = [dirname '/samples/'];

% dimensional parameters
shearlayer.width = 5; % h* (m)
shearlayer.vjmp = 0.5; % u* (m/s) velocity jump
shearlayer.Bjmp = 1e-3 * shearlayer.width; % B* buoyancy jump
shearlayer.timescale = shearlayer.width/shearlayer.vjmp;

% sampling parameters
samp.pump_z = 2; % (m) pumping vertical amplitude
samp.pump_period = 5; % (s) pumping frequency
samp.uback = 0.5; % (m/s) background flow? think about shear layer jump

% simulation info form first and last file
fnames = dir([dirname '/*.mat']);
first = load([dirname '/' fnames(1).name], 'sim_info', 'coords');
last = load([dirname '/' fnames(2).name], 'sim_info', 'coords');

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

% (parallel) loop through files and sample along trajectory
ticstart = tic;
mkdir(savedir);
parfor(ff=1:length(fnames), 4)
    disp(['Processing file ' num2str(ff) '/' num2str(length(fnames))]);
    savename = [savedir '/sample_' num2str(ff, '%02d') '.mat'];

    try
        sample_along_trajectory([dirname '/' fnames(ff).name], ...
                                shearlayer, samp, savename);
    catch ME
    end
end
disp('Finished processing files.')
toc(ticstart);

% once sampled, combine and save to savedir/merged.mat
ticstart = tic;
disp('\n\n Merging files.')
samps = dir([savedir '/sample*.mat']);
array_samples = {};
for ff=1:length(samps)
    load([savedir '/' samps(ff).name]);
    array_samples{ff} = sample;
end
sample = merge_cell_structs(array_samples);
sample.samp = samp;
sample.shearlayer = shearlayer;
save([savedir '/merged.mat'], 'sample')
disp('Finished merging files');
toc(ticstart);

process_sample(savedir)
% pcolorcen(slices.eps(:,:,1)');
% hold on;
% scatter(traj.x, traj.z, 64, sample, 'filled', 'markeredgecolor', 'w')
% sample = sample_along_trajectory(slices, traj)