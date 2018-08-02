% i.e. buoyancy budget for the volume bounded by upper boundary
% and the mean buoyancy surface within the sampled volume.
% The LHS is *not* contaminated by reversible wb because we calculate
% mean buoyancy in sorted space using the PDF.

function [totalb, totalbslice, b0z0] = ...
        calc_buoyancy_budget(sample, wda, bpe, iso)

    % calculate mean b bounded by isosurface 'iso' and the top boundary
    totalb = nan([1, size(bpe.Z, 2)]);
    totalbslice = nan([1, size(bpe.Z, 2)]);
    idx = find_approx(bpe.binval, iso);
    zrange = idx:size(bpe.Z, 1);
    for tt=1:size(bpe.bpe, 2)
        % zrange = [find_approx(bpe.Z(:, tt)-12.5, min(sample.traj.z)): ...
        %           find_approx(bpe.Z(:, tt)-12.5, max(sample.traj.z))];

        totalb(tt) = trapz(bpe.binval(zrange), ...
                           bpe.binval(zrange) .* bpe.buoypdf(zrange, tt), 1);
        totalbslice(tt) = trapz(bpe.binval(zrange), ...
                                bpe.binval(zrange) ...
                                .* bpe.buoypdfslice(zrange, tt), 1);


        % meanb(tt) = trapz(bpe.binval(zrange), ...
        %                   bpe.binval(zrange) .* bpe.buoypdf(zrange, tt), 1) ...
        %     / trapz(bpe.binval(zrange), bpe.buoypdf(zrange, tt));
        % meanbslice(tt) = trapz(bpe.binval(zrange), ...
        %                        bpe.binval(zrange) .* bpe.buoypdfslice(zrange, tt), 1) ...
        %     / trapz(bpe.binval(zrange), bpe.buoypdfslice(zrange, tt));;

    end

    % find time-varying z* location of isosurface in sorted space using the
    % buoyancy PDF.
    z0 = bpe.Z(idx, :);

    dt = diff(bpe.time);
    b0z0 = iso .* z0;

    return