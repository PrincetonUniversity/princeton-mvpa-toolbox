function [results] = add_results_history(results,hist_str,displayme)

% Adds a line to the results.header.history field
%
% [RESULTS] = ADD_RESULTS_HISTORY(RESULTS,HIST_STR,[DISPLAYME])
%
% Also creates the header field if it doesn't exist
%
% DISPLAYME (optional, default = false). If true, the HIST_STR gets
% echoed to the screen as well.
%
% See ADD_HISTORY

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


if ~exist('displayme','var')
  displayme = false;
end
  
if ~isfield(results,'header')
  results.header.history=[];
end
if ~isfield(results.header,'history')
  results.header.history = [];
end

hist_str = sprintf('%s: %s',datetime(),hist_str);

results.header.history{end+1}=hist_str;

if displayme
  disp(hist_str);
end

