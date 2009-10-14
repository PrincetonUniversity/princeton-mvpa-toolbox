function [] = display_results_history(results)

% Display the results.history field
%
% [] = DISPLAY_RESULTS_HISTORY(RESULTS)
%
% Displays the freeform text history stored in the results'
% header.history field in a friendly way

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


nHists = length(results.history);
for i=1:nHists
  disp( sprintf('%s',char(results.history{i})) );
end
