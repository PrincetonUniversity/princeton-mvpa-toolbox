function [idx vals] = maxi(mat)

% [IDX VALS] = MAXI(MAT)
%
% Just calls Matlab's built-in MAX function, but returns
% the IDX first.

[vals idx] = max(mat);

