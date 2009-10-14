function [issame] = compare_size(m1,m2)

% Returns true if two matrices are the same size
%
% [issame] = compare_size(m1,m2)
%
% Checks that M1 and M2 have the same number of dimensions and each
% dimension is the same size

% License:
%=====================================================================
%
% This is part of the Princeton MVPA toolbox, released under
% the GPL. See http://www.csbmb.princeton.edu/mvpa for more
% information.
% 
% The Princeton MVPA toolbox is available free and
% unsupported to those who might find it useful. We do not
% take any responsibility whatsoever for any problems that
% you have related to the use of the MVPA toolbox.
%
% ======================================================================


issame = true;

if ndims(m1) ~= ndims(m2)
  issame = false;
  return
end

if ~all(size(m1)==size(m2))
  issame = false;
  return
end

