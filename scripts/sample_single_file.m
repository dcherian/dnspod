function [] = sample_single_file(filename, savename, simdir, ff, layer, samp)

    file = load(filename);

    % sample the saved fields
    sample = sample_along_trajectory(file, layer, samp);
    save(savename, 'sample');

    % merge the mean fields together
    means = file.means;
    save([simdir '/means/means_' num2str(ff, '%02d') '.mat'], 'means');
end