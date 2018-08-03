% [sample, wda] = process_sampled_field(savedir, dt)
% Input
% -----
%     savedir: directory with sample.mat
%     dt : chunk length (wda.dt)
%
% Output
% ------
%     sample : the 'sample' structure
%     wda : structure with inferred chi, KT etc.

function [sample, wda] = process_sampled_field(savedir, dt)

    % dt = 60; % (s) length of time chunk over which to average

    load([savedir '/merged.mat'])
    load([savedir '/../../bpe.mat'])

    % decimate χ, eps to "1 second".
    % TODO: I am averaging here; should I sample?
    window = round(1/nanmedian(diff(sample.t * sample.layer.timescale)));
    if window < 3
        disp(['1 second windows for chi, eps subsampling are ' ...
              num2str(window) ' points long!']);
    end

    chi.chi = moving_average(sample.chi, window, window);
    chi.eps = moving_average(sample.eps, window, window);
    chi.T = moving_average(sample.b, window, window);
    chi.time = moving_average(sample.t, window, window);

    % vertical displacement structure
    vdisp.dis_z = -sample.traj.z';
    vdisp.time = sample.t';

    % T observations, here buoyancy b
    T.time = sample.t';
    T.Tenh = sample.b';
    T.T = sample.b';

    % Set tp to chi
    Tp.tp = sample.chi';
    Tp.time = sample.t';

    ndt = round(dt./nanmedian(diff(sample.t * sample.layer.timescale)));

    plotflag = 0; % set 1 to debug
    idx = 1;
    avgs = {};
    for t0=1:ndt:length(sample.t)
        avgs{idx} = winters_dasaro_avg(t0, min(t0+ndt, length(sample.t)), ...
                                       vdisp, chi, T, Tp, dt, plotflag, bpe);

        idx = idx+1;
    end

    chi_wda = merge_cell_structs(avgs, 2);
    chi_wda.dt = dt;

    wda = process_wda_estimate(chi, chi_wda);
    wda.Tzi = chi_wda.Tzi;

    wda.zsort = chi_wda.zsort;
    wda.Tbins = chi_wda.Tbins;

    wda.zsort_full = chi_wda.zsort_full;
    wda.binval = bpe.binval;

    wda.zsort_true = nan(size(wda.zsort));
    for tt = 1:size(wda.zsort, 2)
        wda.zsort_true(:, tt) = interp1(wda.binval, ...
                                        wda.zsort_full(:, tt), ...
                                        wda.Tbins(:, tt));
    end

    wda.dz = chi_wda.dz(1:end-1, :); % estimated separation between isotherms
    wda.dz_true = diff(wda.zsort_true, 1); % true separation between isotherms
    wda.dz_rmse = sqrt(nansum((wda.dz_true - wda.dz).^2, 1)); % RMSE in dz estimate
end

% % choose buoyancy (isoscalar) surfaces
% bvec = chi.b(chit0:chit1);
% bins = [prctile(bvec, 5), quantile(bvec, nbins-1), prctile(bvec, 95)];

% [~, locs1] = findpeaks(sample.traj.z(it0:it1));
% [~, locs2] = findpeaks(-sample.traj.z(it0:it1));
% locs = sort([it0, locs1+it0-1, locs2+it0-1, it1]);

% clear dzmat
% for ll = 1:length(locs)-1
%     l0 = locs(ll); l1 = locs(ll+1);

%     zvec = sample.traj.z(l0:l1);
%     Tvec = -sample.b(l0:l1);

%     % account for non-uniform Δz

%     Tsort = -thorpeSort(-Tvec);

%     zbins = interp1(Tsort, zvec, bins);

%     dzmat(:, ll) = diff(zbins);
% end

% dz = nanmean(dzmat, 2)';
% numgood = sum(~isnan(dzmat), 2);
% dz(numgood < 3) = NaN;
% dzdT = dz./diff(bins);

% wda.chi = isoscalar_average(chi.chi(chit0:chit1), chi.b(chit0:chit1), bins);
% wda.eps = isoscalar_average(chi.chi(chit0:chit1), chi.b(chit0:chit1), bins);
