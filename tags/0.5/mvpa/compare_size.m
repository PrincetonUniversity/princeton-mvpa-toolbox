function [issame] = compare_size(m1,m2)

% Returns true if two matrices are the same size
%
% [issame] = compare_size(m1,m2)
%
% Checks that M1 and M2 have the same number of dimensions and each
% dimension is the same size



issame = true;

if ndims(m1) ~= ndims(m2)
  issame = false;
  return
end

if ~all(size(m1)==size(m2))
  issame = false;
  return
end

