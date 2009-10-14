function [filt] = normfilt(n, fwhm, d)
% Gaussian (Normal) filter of specified width, FWHM, and dimension.
% 
% Usage:
%
%  [FILT] = NORMFILT(N, FWHM, D)
%
% Returns a Gaussian filter FILT with N samples and a Full-Width
% Half Max of FWHM samples. D is the number of dimensions of the
% filter; either 1, 2, or 3 dimensional filters are
% supported. 
% 
% This is useful for convolution to perform smoothing.
%
% SEE ALSO
%  BLUR_PATTERN, CONVN

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

if nargin==2
  d = 1;
end

if d > 3
  error('Too many dimensions.');
end

% Generate points in the filter
if d == 1
  pts = -n:n;
elseif d == 2
  [x,y] = meshgrid(-n:n, -n:n);
  pts = [x(:) y(:)];
elseif d == 3
  [x,y,z] = meshgrid(-n:n, -n:n, -n:n);
  pts = [x(:) y(:) z(:)];
end

% Calculate standard deviation of normal distribution
sigma = fwhm / (2*sqrt(2*log(2)));


if d > 1
  % Create covariance/means matrix
  V = eye(d).*sigma;

  filt = mvnpdf(pts, 0, V);
  filtsize = repmat(numel(-n:n),1,d);
  filt = reshape(filt, filtsize);
else 
  filt = normpdf(pts, 0, sigma);
end


% Make sure that filter sums to noe
filt = filt ./ sum(filt(:));