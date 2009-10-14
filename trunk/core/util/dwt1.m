function [approx detail] = dwt1(X, g, h)
% Performs a single level discrete wavelet transform.
%
% [approx detail] = dwt1(X, g, h)

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

approx = conv2(X, g, 'same');
detail = conv2(X, h,'same');

% downsample by 2
approx = approx(2:2:end);
detail = detail(2:2:end);


