function [] = sample_single_file(filename, savename, simdir, ff, layer, samp)

    file = load(filename);

    sample_along_trajectory(file, layer, samp, savename);

    % this stuff just gets merged
    bpe = file.bpe;
    means = file.means;

    save([simdir '/bg/means_' num2str(ff, '%02d') '.mat'], 'means');
    save([simdir '/bg/bpe_' num2str(ff, '%02d') '.mat'], 'bpe');

end