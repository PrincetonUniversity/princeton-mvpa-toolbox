function [h,theImage] = MakeGrayImageFigureForMatrix(matrix,figname,figScale)
%MakeGrayImageFigureForMatrix	Make a grayscale image figure out of a matrix
%	[h,theImage] = MakeGrayImageFigureForMatrix(matrix,figname,figScale)
%				matrix = 2D matrix to make a gray image of
%				figname = name of figure
%				figScale = scale factor for figure/matrix-- optional
%
%See also Matrix2Grayscale
%
%History
%
%	7/26/2002		bds		wrote it for matwave package, D.R.Williams' lab
%	8/18/2002		bds		removed figSide parameter-- use size of matrix*figScale
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

% convert to grayscale
theImage =  Matrix2Grayscale(matrix);
if nargin == 2
	figScale = 1;
end
h = CenteredNamedFigure(figname,size(theImage).*figScale);
% draw the image into the figure
image(theImage);