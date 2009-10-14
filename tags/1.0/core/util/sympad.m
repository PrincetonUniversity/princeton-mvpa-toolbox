function [X] = sympad(X, pad)
% Performs symmetric padding to expand signal X on both ends by n points.
%
% This is useful to avoid falloff when doing convolution.
% X is an N x P matrix of signals.

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

% Default padding: the entire frickin' signal
if nargin==1
  pad = cols(X);
end

symLeft = X(pad:-1:2,:);
symRight = X(end-1:-1:end-pad, :);

% Do symmetric padding:
X = vertcat(symLeft, X, symRight);
