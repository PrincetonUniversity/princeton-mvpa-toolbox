function [path] = genpathsafe(dir)
% Generates paths while excluding directories that begin with a dot.
%
% [PATH] = GENPATHSAFE(DIR)
%
% Generates paths while excluding directories that begin with a
% dot. This way it is possible to add source control repositories
% to the path without adding tons of unnecessary paths in the process.

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


path = regexprep(genpath(dir), '(\w|[/~\-])*/\.(\w|[/\-])*:', '');

