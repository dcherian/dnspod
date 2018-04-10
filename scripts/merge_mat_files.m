% Merges a bunch of matfiles in 'savedir' found using 'globstr'
%
% [merged] = merge_mat_files(savedir, globstr, make_2d, concat_dim_2d)
%
% make_2d : For 1D inputs
%                   if 0 (default), this routine combines 1d vectors
%                                   to make a long 1d vector
%                   if 1, this routine combines 1d vectors to yield a 2d array
%  concat_dim_2d :  For 2D inputs
%                   concat_dim_2d is the dimension along which to concatenate
%                   (passed on to cat)

function [merged] = merge_mat_files(savedir, globstr, make_2d, concat_dim_2d)


    if ~exist('make_2d', 'var'), make_2d = 0; end
    if ~exist('concat_dim_2d', 'var'), concat_dim_2d = 1; end

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

    merged = merge_cell_structs(array_merged, make_2d, concat_dim_2d);
end