function [X] = idwt1(approx, detail, g_i, h_i, len)
% Performs a 1-dimensional single inverse discrete wavelet transform.
%
% [X] = idwt1(approx, detail, g_i, h_i, len)

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

% upsample:
approx = up(approx);
detail = up(detail);

approx = conv(approx, g_i);
detail = conv(detail, h_i);

% reconstruct
X = approx + detail;

n = (numel(X)-len)/2;
X = X((floor(n)+1):(end-ceil(n)));


% Upsampling utility function
function [y] = up(x)

y = zeros(1,numel(x)*2);
y(2:2:end) = x;

