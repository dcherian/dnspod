function [sample] = sample_along_trajectory(file, layer, samp)

    % file.coords is non-dimensional
    % dim is dimensional
    dim.x = file.coords.x;
    dim.z = file.coords.z;
    dim.t = file.coords.t;
    dim.t0 = samp.t0;
    dim.LX = file.sim_info.LX;
    dim.LZ = file.sim_info.LZ;

    % build trajectory
    traj.t = dim.t; %dim.t(1):0.01:dim.t(end); % sample at 100Hz
    tvec = traj.t - dim.t0; % gets traj.x right when processing files in parallel.

    traj.z = samp.pump_z * sin(2*pi/samp.pump_period * tvec);
    traj.x = mod(samp.uback * tvec(1) + samp.uback * (tvec-tvec(1)), dim.LX);
    traj.x(abs(traj.x - dim.LX) < 1e-5) = dim.LX;

    % sample the file.slices along trajectory
    fields = fieldnames(file.slices);
    for fld = 1:length(fields)
        [xmat, zmat, tmat] = ndgrid(dim.x, dim.z, dim.t);
        F = griddedInterpolant(xmat, zmat, tmat, file.slices.(fields{fld}));
        sample.(fields{fld}) = F(traj.x, traj.z, traj.t);
    end
    sample.traj = traj;
    sample.t = traj.t;
    sample.traj.tref = tvec;
    sample.layer = layer;
end