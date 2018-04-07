function [] = process_sample(savedir)

    nbins = 7; % number of isoscalar surfaces to average between
    dt = 60; % (s) length of time chunk over which to average

    load([savedir '/merged.mat'])

    % decimate χ, eps to "1 second".
    % TODO: I am averaging here; should I sample?
    window = round(1/nanmedian(diff(sample.t)));
    if window < 3, disp('1 second windows are < 3 points long.'); end

    chi.chi = moving_average(sample.chi, window, window);
    chi.eps = moving_average(sample.eps, window, window);
    chi.T = moving_average(sample.b, window, window);
    chi.time = moving_average(sample.t, window, window);

    t0 = sample.t(1);
    t1 = t0 + dt;

    it0 = find_approx(sample.t, t0);
    it1 = find_approx(sample.t, t1);

    % vertical displacement structure
    vdisp.dis_z = sample.traj.z';
    vdisp.time = sample.t;

    % T observations, here buoyancy b
    T.time = sample.t;
    T.Tenh = sample.b';
    T.T = sample.b;

    % Set tp to chi
    Tp.tp = sample.chi;
    Tp.time = sample.t;

    plotflag = 1;

    wda = winters_dasaro_avg(it0, it1, vdisp, chi, T, Tp, dt, plotflag);

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
