function [goodness ondiags_val offdiags_val] = onoff_metric(mat)

% [GOODNESS ONDIAGS_VAL OFFDIAGS_VAL] = ONOFF_METRIC(MAT)
%
% Calculate the OnOff metric, as in pg 12 of the supporting
% materials of Polyn et al (2005). Subtracts the mean of the
% off-diagonals from the mean of the on-diagonals.

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

% get the indices of the diagonal entries
ondiags_idx = find(eye(size(mat)));
% get their values
ondiags_val = mat(ondiags_idx);

% get the indices of the off-diagonal entries
offdiags_idx = find(eye(size(mat))==0);
% get their values
offdiags_val = mat(offdiags_idx);

% this could perhaps be a ratio, but we decided to follow
% Polyn et al (2005) for now, and stick with a subtraction
goodness = mean(ondiags_val) - mean(offdiags_val);

