% this function should figure out when
% we have pure turbulence and no rollups.
% return a time range
function [trange] = get_turb_time_range(sample)

    trange = [find_approx(sample.t, 140):length(sample.b)];

end