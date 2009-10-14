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


if ischar(objnames)
  objnames = {objnames};
end

for m=1:length(objnames)
  subj = set_objfield(subj,objtype,objnames{m},'group_name',new_group_name);
end % m objnames



