function [Jq] = interpolate_Jq_to_iso(wda, iso)

   Jq = nan(length(iso), size(wda.Jmat, 2));

   for tt = 1:size(wda.Jmat, 2)
       if all(isnan(wda.Tcen(:, tt))), continue; end
       Jq(:, tt) = interp1(wda.Tcen(:, tt), wda.Jmat(:, tt), iso, 'nearest');
   end
end