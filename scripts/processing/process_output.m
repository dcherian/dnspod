% Main function to process simulation output
%
% Inputs
% ------
%    simdir : Directory with output
%    layer : structure with shear layer parameters
%            (not used for anything; just copied to output
%             as reference)
%    samp : structure with sampling parameters
%
% Outputs
% -------
%    None
function [] = process_output(simdir, layer, samp)

    savedir = [simdir '/samples/'];

    mkdir(savedir); % for along-trajectory samples
    mkdir([simdir '/means']); % for mean fields

    % simulation info from first and last file
    fnames = dir([simdir '/slices*.mat']);
    first = load([simdir '/' fnames(1).name], 'coords', 'sim_info');

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

    %% merge bpe & means to separate files.
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