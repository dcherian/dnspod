function [sample] = sample_along_trajectory(filename, shearlayer, samp, savename)

    load(filename);

    % coords is non-dimensional
    % dim is dimensional
    dim.x = coords.x * shearlayer.width;
    dim.z = coords.z * shearlayer.width;
    dim.t = coords.t * shearlayer.timescale;
    dim.LX = sim_info.LX * shearlayer.width;
    dim.LZ = sim_info.LZ * shearlayer.width;

    % build trajectory
    traj.t = dim.t;
    traj.x = mod(samp.uback * traj.t, dim.LX); % + 10 * sin(2*pi*traj.t/50);
    traj.x(abs(traj.x - dim.LX) < 1e-5) = dim.LX;
    traj.z = samp.pump_z * sin(2*pi/samp.pump_period * traj.t);

    fields = fieldnames(slices);
    for fld = 1:length(fields)
        [xmat, zmat, tmat] = ndgrid(dim.x, dim.z, dim.t);
        F = griddedInterpolant(xmat, zmat, tmat, slices.(fields{fld}));
        sample.(fields{fld}) = F(traj.x, traj.z, traj.t);
    end
    sample.traj = traj;
    sample.t = dim.t;

    save(savename, 'sample');

end