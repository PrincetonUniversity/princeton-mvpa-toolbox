function theImage = Matrix2Grayscale(matrix)
%Matrix2Grayscale	Make a grayscale image from an input 2D matrix
%	theImage = Matrix2Grayscale(matrix)
%
%	Used by MakeGrayImageFigureForMatrix
%
%See also MakeGrayImageFigureForMatrix
%
%History
%
%	7/26/2002	bds		wrote it for matwave package, D.R.Williams' lab
%	8/20/2002	bds		broke out normalizing to 0..1 into MaximizeContrast.m
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

% scale so 0 is min, max is 255
theImage = MaximizeContrast(matrix) .* 255;

% transform to 8 bit
theImage = uint8(theImage);
% convert to truecolor (3 x 8 bit values = 24 bits per pixel)
% 8bpp forces indexed color, which can lead to reduced gamut since colormap is used
% and lots of color entries (nearly 20%) are reserved for the system-- bad for a 'gray' colormap.
theImage = repmat(theImage,[1 1 3]); 