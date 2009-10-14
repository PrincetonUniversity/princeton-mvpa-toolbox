function [y] = create_legendre(timepoints, N, norm) 
% Generates legendre polynomials of specified order.
%
% Usage:
%
%  [Y] = CREATE_LEGENDRE(N, POLORT)
%  [Y] = CREATE_LEGENDRE(N, POLORT, NORM)
%
% Generates legendre polynomials of order up to POLORT with norm NORM
% (default NORM 'unnorm'). Spaces the polynomial across N timepoints.

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

if nargin<3
  norm = 'unnorm';
end

% Check for empty
if N == 0
  y = [];
  return;
end

X = linspace(-1, 1, timepoints);

y = [];
for n = 1:N
  l = legendre(n, X, norm);
  y = vertcat(y, l(1,:));
end
