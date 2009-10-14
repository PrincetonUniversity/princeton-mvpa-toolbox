function [shuffled idx] = shuffle(mat,dim)

% Shuffles the order of a vector or 2D matrix
%
% [shuffled] = shuffle(mat,[dim])
%
% DIM (optional, default = 1), determines which dimension to use to
% shuffle the matrix
%
% Can't deal with >2D matrices. Any suggestions?

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


if ~exist('dim','var')
  dim = 1;
end

if isempty(mat)
  shuffled = [];
  return
end

if ndims(mat)>2
  error('Can''t deal with multi-dimensional matrices');
end
if dim<1
  error('Dim must be greater than 1');
end
if dim>ndims(mat)
  error('Dims must be less than the number of dimensions in the matrix');
end

if isvector(mat)
  matsize = length(mat);
else
  matsize = size(mat,dim);
end

[vals idx] = sort(rand([1 matsize]));

if isvector(mat)
  shuffled = mat(idx);
  return
end

switch(dim)
 case 1
  shuffled = mat(idx,:);
 case 2
  shuffled = mat(:,idx);
 otherwise
  error('Can''t deal with matrices of >3 dimensions');
end

