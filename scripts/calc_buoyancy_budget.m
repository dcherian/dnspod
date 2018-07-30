% i.e. buoyancy budget for the volume bounded by upper boundary
% and the mean buoyancy surface within the sampled volume.
% The LHS is *not* contaminated by reversible wb because we calculate
% mean buoyancy in sorted space using the PDF.

function [iso, meanb, meanbslice, int_b0dz0dt] = ...
    calc_buoyancy_budget(sample, wda, bpe, weights)

    wda.Jq = repnan(wda.Jq, 0);

    if strcmp(weights,  'Jq')
        buoy = wda.T;
        weights = wda.Jq;
        time = wda.time;
    else
        buoy = sample.b;
        weights = ones(size(sample.b));
        time = sample.t;
    end

    dt = diff(time); dt = [dt(1), dt];
    weights = abs(weights)/sum(abs(weights) .* dt);
    iso = sum(buoy .* weights .* dt)  % isosurface

    meanb = nan([1, size(bpe.Z, 2)]);
    idx = find_approx(bpe.binval, iso);
    zrange = idx:size(bpe.Z, 1);
    for tt=1:size(bpe.bpe, 2)
        % zrange = [find_approx(bpe.Z(:, tt)-12.5, min(sample.traj.z)): ...
        %           find_approx(bpe.Z(:, tt)-12.5, max(sample.traj.z))];

        meanb(tt) = trapz(bpe.binval(zrange), ...
                          bpe.binval(zrange) .* bpe.buoypdf(zrange, tt), 1) ...
            / trapz(bpe.binval(zrange), bpe.buoypdf(zrange, tt));
        meanbslice(tt) = trapz(bpe.binval(zrange), ...
                               bpe.binval(zrange) .* bpe.buoypdfslice(zrange, tt), 1) ...
            / trapz(bpe.binval(zrange), bpe.buoypdfslice(zrange, tt));;
    end

    % find time-varying z* location of isosurface in sorted space using the
    % buoyancy PDF.
    z0 = bpe.Z(idx, :);
    dt = diff(bpe.time);
    b0dz0dt = iso .* diff(z0)./diff(bpe.time);
    int_b0dz0dt = [0, cumtrapz(avg1(bpe.time), b0dz0dt)];

    return