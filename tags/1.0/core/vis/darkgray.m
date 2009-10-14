function [newmap] = darkgray(m)
% DARKGRAY- A darker gray colormap than GRAY.
%
% SEE ALSO
%   GRAY, COLORMAP

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

if nargin < 1
  m = 32;
end

bottom = [0.05 0.05 0.05];
top = [0.5 0.5 0.5];

xi = linspace(0, 1, m);

newmap = interp1([0 1], [bottom; top], xi);


