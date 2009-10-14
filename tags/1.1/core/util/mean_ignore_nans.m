function [med] = mean_ignore_nans(vec)

% Calculate the mean of vector VEC, excluding NaNs
%
% [MED] = MEAN_IGNORE_NANS(VEC)


if ~isvector(vec)
  error('VEC must be a vector');
end

vec = vec(find(~isnan(vec)));
med = mean(vec);
