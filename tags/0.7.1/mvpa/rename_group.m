function [subj] = rename_group(subj,objtype,old_groupname,new_groupname)

% Changes the groupname for all objects in a group
%
% [SUBJ] = RENAME_GROUP(SUBJ,OBJTYPE,OLD_GROUPNAME,NEW_GROUPNAME)
%
% This goes through all the objects of a specific type, finds those
% with group_name OLD_GROUPNAME, and sets it instead to
% NEW_GROUP_NAME
%
% I think this is safe to do, but changes the name or group_name of
% an object are not recommended

% This is part of the Princeton MVPA toolbox, released under the
% GPL. See http://www.csbmb.princeton.edu/mvpa for more
% information.


if nargin < 4
  error('I think you''ve forgotten to feed in all your arguments');
end

if ~nargout
  error('Don''t forget to catch the subj structure that gets returned');
end

members = find_group(subj,objtype,old_groupname);

for m=1:length(members)
  subj = set_objfield(subj,objtype,members{m},'group_name',new_groupname);
end % m members

