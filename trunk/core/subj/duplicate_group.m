function [subj new_objnames group_mat] = duplicate_group(subj,objtype,old_groupname,new_groupname)

% Duplicate an entire group
%
% [SUBJ NEW_OBJNAMES GROUP_MAT] = DUPLICATE_GROUP(SUBJ,OBJTYPE,OLD_GROUPNAME,NEW_GROUPNAME)
%
% Calls DUPLICATE_OBJECT on each object in the group, renaming them
% based on the NEW_GROUPNAME
% 
% Requires each OBJNAME to be
% sprintf('%s_%i',OLD_GROUPNAME,objnum). [Actually, I think it just
% requires OLD_GROUPNAME to be part of the object name, so
% that it can do a find/replace for it].
%
% GROUP_MAT = results of GET_GROUP_AS_MATRIX.


if ~nargout
  error('Don''t forget to catch the subj structure that gets returned');
end
if nargin<4
  error('I think you''ve forgotten to feed in all your arguments');
end


if ~exist_group(subj,objtype,old_groupname)
  error('No group called %s',old_groupname);
end

old_objnames = find_group(subj,objtype,old_groupname);
new_objnames = {};
nObjs = length(old_objnames);
for o=1:nObjs
  old_objname = old_objnames{o};

  if length(strfind(old_objname,old_groupname))~=1
    % e.g. if OLD_GROUPNAME = 'blah', then we'd expect the objects to
    % be 'blah_1', 'blah_2' etc.
    error('This function requires the object names in the group being copied to be based on the group name');
  end
  
  % replace incidences of OLD_GROUPNAME in OLD_OBJNAME with
  % NEW_GROUPNAME, e.g. 'foo_1' -> 'bar_1'
  new_objname = strrep(old_objname,old_groupname,new_groupname);
  subj = duplicate_object(subj,objtype,old_objname,new_objname);
  new_objnames{end+1} = new_objname;
  
  % store history of how this came to be
  created = [];
  created.datetime = datetime(true);
  created.dbstack = dbstack;
  created.function = mfilename;
  created.old_groupname = old_groupname;
  created.old_objname = old_objname;
  % we're using SET_OBJFIELD rather than ADD_CREATED here because we
  % don't want to keep any fields that were part of the previous
  % object
  subj = set_objfield(subj,objtype,new_objname,'created',created, ...
                           'ignore_created',true);
    
end % o nObjs

% now update all the new objects to be part of their own group
subj = change_objgroup(subj,objtype,new_objnames,new_groupname);

group_mat = get_group_as_matrix(subj,objtype,old_groupname);
