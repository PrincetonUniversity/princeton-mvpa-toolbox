function [y] = ste(x,dim)

% Calculate the standard error of the mean for X.
%
% [Y] = STE(X,DIM)
%
% Matlab doesn't have a standard error function, but it's easy
% enough to calculate. ste(x) = std(x)/sqrt(n) where n is the
% number of samples.
%
% If you don't specify DIM, it will run on the first
% non-singleton dimension. It uses STD's default
% normalization behavior.

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

% took this trick for finding the first non-singleton
% dimension from mean.m
if nargin==1, 
  % Determine which dimension SUM will use
  dim = min(find(size(x)~=1));
  if isempty(dim), dim = 1; end
end
  

n = size(x,dim);
y = std(x,[],dim) / sqrt(n);


