function [dist] = euclidn(x,y)

% [DIST] = EUCLIDN(X,Y)
%
% Calculate the Euclidean distance between two n-dimensional
% vectors X and Y.


if ~compare_size(x,y) ~isvector(x)
  error('X and Y must be vectors of the same length');
end

dist = sqrt( ...
    sum( power(x-y, 2) ) ...
    );

