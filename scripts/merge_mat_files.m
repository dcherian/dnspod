function [merged] = merge_mat_files(savedir, globstr, concat_2d)

    if ~exist('concat_2d', 'var'), concat_2d = 0; end

    disp(['\n\n Merging files ... ' globstr])
    samps = dir([savedir globstr]);

    array_merged = {};
    for ff=1:length(samps)
        file = load([savedir '/' samps(ff).name]);
        flds = fields(file);
        if length(flds) == 1
            array_merged{ff} = file.(flds{1});
        else
            array_merged{ff} = file;
        end
    end

    merged = merge_cell_structs(array_merged, concat_2d);
end