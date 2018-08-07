%    [brange] = get_buoy_range(b)
% given a buoyancy time series; return guess for range within
% which budget might work.

function [brange] = get_buoy_range(b)

    % meanb = nanmean(b);
    % stdb = nanstd(b);
    % brange = [-stdb stdb] + meanb;

    brange = [prctile(b, 25) ...
              prctile(b, 75)];

end