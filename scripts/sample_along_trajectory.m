function [sample] = sample_along_trajectory(filename, layer, samp, savename)

    load(filename);

    % coords is non-dimensional
    % dim is dimensional
    dim.x = coords.x * layer.width/2;
    dim.z = coords.z * layer.width/2;
    dim.t = coords.t * layer.timescale;
    dim.LX = sim_info.LX * layer.width/2;
    dim.LZ = sim_info.LZ * layer.width/2;

    % build trajectory
    traj.t = dim.t(1):0.01:dim.t(end); % sample at 100Hz
    traj.z = samp.pump_z * sin(2*pi/samp.pump_period * traj.t);

    uback = samp.uback - layer.vjmp/2 * tanh(traj.z/(layer.width/2));
    traj.x = mod(cumtrapz(traj.t, uback), dim.LX);
    traj.x(abs(traj.x - dim.LX) < 1e-5) = dim.LX;

    % sample the slices along trajectory
    fields = fieldnames(slices);
    for fld = 1:length(fields)
        [xmat, zmat, tmat] = ndgrid(dim.x, dim.z, dim.t);
        F = griddedInterpolant(xmat, zmat, tmat, slices.(fields{fld}));
        sample.(fields{fld}) = F(traj.x, traj.z, traj.t);
    end
    sample.traj = traj;
    sample.t = traj.t;

    % this stuff just gets merged
    sample.bpe = bpe;
    sample.means = means;

    save(savename, 'sample');
end