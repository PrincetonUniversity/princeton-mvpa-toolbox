function [X] = db4idwt(coefficients, levels)
% Imitates the waverec function in wavelet toolbox.
%
% [X] = db4idwt(coefficients, levels)
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

% This is hard coded with values of the db4 wavelet:

g = [0.230377813308855 0.714846570552542 0.63088076792959 ...
     -0.0279837694169838 -0.187034811718881 0.030841381835987 ...
     0.0328830116669829 -0.0105974017849973];

h = [-0.0105974017849973 -0.0328830116669829 0.030841381835987 ...
     0.187034811718881 -0.0279837694169838 -0.63088076792959 ...
     0.714846570552542 -0.230377813308855];

% Now, just do most straightforward IDWT imaginable:
a = grabnext();

for n = 1:(length(levels)-1)

  d = grabnext();
  len = levels(1);
  a = idwt1(a,d, g, h, len); %, levels(n+1));
  
end

X = a;

function [a] = grabnext()

a = coefficients(1:levels(1));
coefficients = coefficients((numel(a)+1):end);
levels = levels(2:end);

end

end
