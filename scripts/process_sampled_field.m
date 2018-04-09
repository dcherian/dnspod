function [sample, wda] = process_sampled_field(savedir)

    nbins = 7; % number of isoscalar surfaces to average between
    dt = 30; % (s) length of time chunk over which to average

    load([savedir '/merged.mat'])

    % decimate χ, eps to "1 second".
    % TODO: I am averaging here; should I sample?
    window = round(1/nanmedian(diff(sample.t)));
    if window < 3, disp('1 second windows are < 3 points long.'); end

    chi.chi = moving_average(sample.chi, window, window);
    chi.eps = moving_average(sample.eps, window, window);
    chi.T = moving_average(sample.b, window, window);
    chi.time = moving_average(sample.t, window, window);

    % vertical displacement structure
    vdisp.dis_z = sample.traj.z';
    vdisp.time = sample.t';

    % T observations, here buoyancy b
    T.time = sample.t';
    T.Tenh = sample.b';
    T.T = sample.b';

    % Set tp to chi
    Tp.tp = sample.chi';
    Tp.time = sample.t';

    ndt = round(dt./nanmedian(diff(sample.t)));

    plotflag = 0; % set 1 to debug
    idx = 1;
    avgs = {};
    for t0=1:ndt:length(sample.t)
        avgs{idx} = winters_dasaro_avg(t0, min(t0+ndt, length(sample.t)), ...
                                       vdisp, chi, T, Tp, dt, plotflag);

        idx = idx+1;
    end

    chi_wda = merge_cell_structs(avgs, 2);
    chi_wda.dt = dt;

    wda = process_wda_estimate(chi, chi_wda);

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
%     Tvec = sample.b(l0:l1);

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
