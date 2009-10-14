function [subj] = change_objgroup(subj,objtype,objnames,new_group_name)

% Change group name of multiple objects at a time
%
% [SUBJ] = CHANGE_OBJGROUP(SUBJ,OBJTYPE,OBJNAMES,NEW_GROUP_NAME)
%
% This goes through each object in OBJNAMES, changing their
% GROUP_NAME to NEW_GROUP_NAME
%
% OBJNAMES is a cell array of object name strings, or a single
% object name string.

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


if ischar(objnames)
  objnames = {objnames};
end

for m=1:length(objnames)
  subj = set_objfield(subj,objtype,objnames{m},'group_name',new_group_name);
end % m objnames



