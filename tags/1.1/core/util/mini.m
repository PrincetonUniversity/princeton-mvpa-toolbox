function [idx vals] = mini(mat)

% [IDX VALS] = MINI(MAT)
%
% Just calls Matlab's built-in MIN function, but returns
% the IDX first.

[vals idx] = min(mat);

