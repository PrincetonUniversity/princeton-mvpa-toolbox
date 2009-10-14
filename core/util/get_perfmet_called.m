function [pm_no] = get_perfmet_called(results,desired_name)

% [PM_NO] = GET_PERFMET_CALLED(RESULTS,DESIRED_NAME)
%
% If you have only one perfmet, this will return
% 1. DESIRED_NAME must be empty or the name of the single
% perfmet.
%
% If you have multiple perfmets, this will return the index
% of the one that matches DESIRED_NAME.

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

pm = results.iterations(1).perfmet;
nPerfmets = length(pm);

if nPerfmets==1
  if ~isempty(desired_name) & ~strcmp(desired_name,pm.function_name)
    error('You fed in a perfmet name that doesn''t match your only perfmet')
  end
  
  pm_no = 1;
  return
end % single perfmet

possible_names = {};
for p=1:nPerfmets
  possible_names{end+1} = pm{p}.function_name;
end
pm_no = strmatch(desired_name, possible_names,'exact');

switch length(pm_no)
 case 0
  error('No perfmet called %s',desired_name)
 case 1
  return
 otherwise
  error('More than one match for %s',desired_name);
end


