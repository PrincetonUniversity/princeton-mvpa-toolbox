function h = CenteredNamedFigure(figname,figSize)
%CenteredNamedFigure	Create and center a figure on the screen
%	h = CenteredNamedFigure(figname,figSize)
%
%History
%
%	7/26/2002	bds		wrote CenteredNamedSquareFigure as part of matwave package, D.R.Williams' lab
%	8/18/2002	bds		removed square requirement-- pass in size of figure
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

% create figure
h = figure('Name',figname);
% set it to be figSide x figSide resolution
set(0,'Units','pixels') 
scnsize = get(0,'ScreenSize');
scnWidth = scnsize(3);
scnHeight = scnsize(4);
figLeft = scnWidth/2 - figSize(2)/2;
figBot = scnHeight/2 - figSize(1)/2;
figpos = [figLeft figBot figSize(2) figSize(1)];
set(h,'Position',figpos);