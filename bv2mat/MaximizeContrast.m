function theImage = MaximizeContrast(matrix)
%MaximizeContrast	Normalize an image to 0..1 where 0 is the minimum, 1 the maximum
%	theImage = MaximizeContrast(matrix)
%
%	Used by Matrix2Grayscale
%
%See also Matrix2Grayscale
%
%History
%
%   8/20/2002   bds     part of matwave package, D.R.Williams' lab
%	8/20/2002	bds		broke it out of Matrix2Grayscale so it can be used elsewhere
%

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

% transform to real, double units
theImage = matrix;
theImage = real(double(matrix));

% find range of intensities
minVal =  min(min(theImage));
maxVal = max(max(theImage));
range = maxVal - minVal;
if range == 0
    range = minVal;
else
    % scale so 0 is min, max is 1
	theImage = theImage - minVal;
end
theImage = theImage ./ range;