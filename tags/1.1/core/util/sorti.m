function [idx vals] = sorti(mat)

% [IDX VALS] = SORTI(MAT)
%
% Just calls Matlab's built-in SORT function, but returns
% the IDX first.

[vals idx] = sort(mat);

