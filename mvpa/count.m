function [n] = count(x)

% Returns the number of non-zero values in X
%
% N = COUNT(X)


n = length(find(x));

