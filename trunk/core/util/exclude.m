function [new_idx] = exclude(idx, N)
% function [new_idx] = exclude(idx, N)

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

strip = ones(N, 1);
strip(idx) = 0;
new_idx = find(strip);
