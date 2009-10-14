function [t] = titlef(varargin)

% Like calling title(sprintf(X),'Interpreter','None')
%
% This is just a shortcut for plotting graphs.

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

title( sprintf(varargin{:}), 'Interpreter','None' )
