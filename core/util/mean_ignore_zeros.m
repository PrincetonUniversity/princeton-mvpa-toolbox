function [mu] = mean_ignore_zeros(vec)

% Calculate the mean of vector VEC, excluding zeros
%
% [MU] = MEAN_IGNORE_ZEROS(VEC)


if ~isvector(vec)
  error('VEC must be a vector');
end

vec = vec(find(vec~=0));
mu = mean(vec);
