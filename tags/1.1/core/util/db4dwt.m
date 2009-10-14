function [coefficients levels] = db4dwt(X, N)
% Imitates the wavedec function in wavelet toolbox.
%
% [coefficients levels] = db4dwt(X, N)
%
% This is hard coded with values of the 'db4' wavelet taken from
% online resources.

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

% The db4 wavelet: not perfect, but whatever
g   = [-0.0105974017849973 0.0328830116669829 0.030841381835987 ...
       -0.187034811718881 -0.0279837694169838 0.63088076792959 ...
       0.714846570552542 0.230377813308855];

h   = [-0.230377813308855 0.714846570552542 -0.63088076792959 ...
       -0.0279837694169838 0.187034811718881 0.030841381835987 ...
       -0.0328830116669829 -0.0105974017849973];

% Now, just do the most straightforward DWT imaginable:

coefficients = [];
levels = numel(X);

for n = 1:N

  [a,d] = dwt1(X, g, h);
  levels = [length(d) levels];
  coefficients = [d coefficients];
  X = a;
  
end

levels = [length(a) levels];
coefficients = [a coefficients];
