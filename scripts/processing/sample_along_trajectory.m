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

        % sample "mooring gradient" at traj.x
        % do this for many separations
        if fields{fld} == 'b'
            NZ = file.sim_info.NZ - 1;

            iz = 1;
            for zz=3:3:(NZ/2)
                zp = NZ/2 + 1 + zz;
                zm = NZ/2 + 1 - zz;

                sample.moor.dzm(iz, 1) = diff(file.coords.z([zm, zp]));
                sample.moor.Tzm(iz, :) = ...
                    diff(F(repmat(traj.x, [2, 1]), ...
                           repmat(file.coords.z([zm, zp])', [1 length(traj.t)]), ...
                           repmat(traj.t, [2, 1])), 1) / sample.moor.dzm(iz);

                iz = iz+1;
            end

            sample.moor.t = traj.t;
        end
    end

    sample.traj = traj;
    sample.t = traj.t;
    sample.time = sample.t;
    sample.traj.tref = tvec;
    sample.layer = layer;
end