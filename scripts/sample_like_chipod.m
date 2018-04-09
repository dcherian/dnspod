dirname = '../simulation_slices_Re1000Ri012Pr1/';

savedir = [dirname '/samples/'];

% simulation info from first and last file
fnames = dir([dirname '/*.mat']);
first = load([dirname '/' fnames(1).name]);

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

% last = load([dirname '/' fnames(2).name], 'sim_info', 'coords');

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
failed = [];
ticstart = tic;
mkdir(savedir);
parfor(ff=1:length(fnames), 4)
    disp(['Processing file ' num2str(ff) '/' num2str(length(fnames))]);
    savename = [savedir '/sample_' num2str(ff, '%02d') '.mat'];

    try
        sample_along_trajectory([dirname '/' fnames(ff).name], ...
                                layer, samp, savename);
    catch ME
        failed = [failed ff]
        disp(ME);
    end
end
disp('Finished processing files.')
disp('Failed = ')
disp(failed)
toc(ticstart);

% once sampled, combine and save to savedir/merged.mat
% merge 'means' properly and save that to simulation directory
ticstart = tic;
disp('\n\n Merging files.')
samps = dir([savedir '/sample*.mat']);
array_samples = {};
means_cell = {};
for ff=1:length(samps)
    load([savedir '/' samps(ff).name]);
    means_cell{ff} = sample.means;
    array_samples{ff} = rmfield(sample, 'means');
end
sample = merge_cell_structs(array_samples);
sample.samp = samp;
sample.layer = layer;
sample.sim_info = first.sim_info;
means = merge_cell_structs(means_cell, 1);
save([dirname '/means.mat'], 'means')
save([savedir '/merged.mat'], 'sample')
disp('Finished merging files');
toc(ticstart);

%%
[sample, wda] = process_sampled_field(savedir);

% pcolorcen(slices.eps(:,:,1)');
% hold on;
% scatter(traj.x, traj.z, 64, sample, 'filled', 'markeredgecolor', 'w')
% sample = sample_along_trajectory(slices, traj)