% [merged] = merge_struct_array(in, concat_2d)
%           in : array of structures
%      make_2d : For 1D inputs
%                   if 0 (default), this routine combines 1d vectors
%                                   to make a long 1d vector
%                   if 1, this routine combines 1d vectors to yield a 2d array
%  concat_dim_2d :  For 2D inputs
%                   concat_dim_2d is the dimension along which to concatenate
%                   (passed on to cat)

function [merged] = merge_struct_array(in, make_2d, concat_dim_2d)

    if ~exist('make_2d', 'var'), make_2d = 0; end
    if ~exist('concat_dim_2d', 'var'), concat_dim_2d = 1; end

    FF = fields(in);
    for ff=1:length(FF)
        if all(size(in(1).(FF{ff})) > 1)
            concat_dim = concat_dim_2d;
        else
            [~, concat_dim] = max(size(in(1).(FF{ff})));
            if make_2d & isvector(in(1).(FF{ff}))
                if concat_dim == 1
                    concat_dim = 2;
                else
                    concat_dim = 1;
                end
            end
        end

        merged.(FF{ff}) = cat(concat_dim, in.(FF{ff}));

    end
end