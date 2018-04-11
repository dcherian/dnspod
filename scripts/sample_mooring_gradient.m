% Takes input data and gets time-series of "mooring gradients".
% I.e. simple difference assumed symmetric about center of shear layer (z=0)

function [moor] = sample_mooring_gradient(file, traj)

    NZ = file.sim_info.NZ - 1;

    [xmat, zmat, tmat] = ndgrid(file.coords.x, file.coords.z, file.coords.t);
    F = griddedInterpolant(xmat, zmat, tmat, file.slices.b);

    iz = 1;
    for zz=5:5:(NZ/2)
        zp = NZ/2 + 1 + zz;
        zm = NZ/2 + 1 - zz;

        moor.dzm(iz) = diff(file.coords.z([zm, zp]));
        moor.Tzm(iz, :) = diff(F(repmat(traj.x, [2, 1]), ...
                            repmat(file.coords.z([zm, zp])', [1 length(traj.t)]), ...
                            repmat(traj.t, [2, 1])), 1) ...
            / moor.dzm(iz);

        iz = iz+1;
    end

    moor.t = traj.t;

end