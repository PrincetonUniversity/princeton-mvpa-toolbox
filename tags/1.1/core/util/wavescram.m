function [S] = wavescram(X, N, M)
% WAVESCRAM - Efficient, toolbox-free wavelet scrambling.
%
% Usage:
%
%  [S] = WAVESCRAM(X, N)
%  [S] = WAVESCRAM(X, N, M)
%
% WAVESCRAM takes an input signal X, performs an N-level discrete
% wavelet transform using the Debauchies-4 wavelet, and then
% generates M new signals that have similar spectral
% characteristics to the original timeseries. Each new sample is
% returned as a row of matrix S. 
%
% The scrambling is accomplished by permuting the wavelet
% coefficients of X within each scaling level; thus, the
% distribution of wavelet coefficients within each level is preserved.
%
% If M is not provided, then only a single sample is generated.
%
% This function provides most of the functionality of
% WAVELET_SCRAMBLE_MULTI, but without the dependency on the Matlab
% Wavelet toolbox.

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
  M = 1;
end

% Symmetric padding length to avoid reconstruction falloff
pad = ceil(sqrt(length(X)));

symX = X(end:-1:1);

% Do symmetric padding:
X = horzcat(symX, X, symX);

% Preallocate for speed
S = zeros(M, length(X));

% Calculate wavelet coefficients only once
[c l] = db4dwt(X, N);

% Repeat for as many samples as wished
cm = c;  % Start with original samples

lvls = dwt1expand(l);

for m = 1:M

  for n = 1:length(l)-1
    idx = find([lvls == n]);
    cm(idx) = cm(idx(randperm(l(n))));
  end    
  
  S(m, :) = db4idwt(cm, l);
  
end


S = S(:, length(symX)+1:end-length(symX));
