function [subj mat] = duplicate_object(subj,objtype,old_objname,new_objname,group_name)

% Duplicate an object
%
% [SUBJ MAT] = DUPLICATE_OBJECT(SUBJ,OBJTYPE,OLD_OBJNAME,NEW_OBJNAME,GROUP_NAME)
%
% Calls init_object to create a new obj called NEW_OBJNAME,
% and then copies across the mat from OLD_OBJNAME and sets
% the derived_from field to OLD_OBJNAME.
%
% Adds the following objects:
% - object
%
% If GROUP_NAME is empty, then sets the new object's group name to be
% empty (i.e. no group). If GROUP_NAME = 'same', it sets the new
% object's group name to be the same as the old object's. If
% unspecified, defaults to empty
%
% Also copies the appropriate required fields for different object types

% This is part of the Princeton MVPA toolbox, released under the
% GPL. See http://www.csbmb.princeton.edu/mvpa for more
% information.


if nargin<4
  error('I think you''ve forgotten to feed in all your arguments');
end

if ~exist('group_name')
  group_name = '';
end

% xxx This check is probably unnecessary???
if exist_objfield(subj,objtype,old_objname,'movehd')
  error( sprintf('Unable to duplicate a %s object that has been moved to HD',objtype) );
end

% Access the object's mat ("Whats your vector, victor?")
mat = get_mat(subj,objtype,old_objname);

% Initialize the new object
subj = init_object(subj,objtype,new_objname);

% Set the new object's mat to the old object's mat
subj = set_mat(subj,objtype,new_objname,mat);

% Set the derived from field
subj = set_objfield(subj,objtype,new_objname,'derived_from',old_objname);

% Group Name: if this is empty, it has no group. If it is 'same',
% its the same as the old obj. default is groupless
if strmatch(group_name,'same')
  group_name = get_objfield(subj,objtype,old_objname,'group_name');
end
subj = set_objfield(subj,objtype,new_objname,'group_name',group_name);

switch objtype
 case 'pattern'
  masked_by = get_objfield(subj,'pattern',old_objname,'masked_by');
  subj = set_objfield(subj,'pattern',new_objname,'masked_by',masked_by);
 
 case 'regressors'
  condnames = get_objfield(subj,'regressors',old_objname,'condnames');
  subj = set_objfield(subj,'regressors',new_objname,'condnames',condnames);
 
 case 'selector'
 
 case 'mask'
  thresh = get_objfield(subj,'mask',old_objname,'thresh');
  subj = set_objfield(subj,'mask',new_objname,'thresh',thresh);
 
 otherwise
  error('Duplicating unknown object type');
end

% Check to see whether any fields were missed out
oldobj = get_object(subj,objtype,old_objname);
newobj = get_object(subj,objtype,new_objname);
if length(fieldnames(oldobj)) ~= length(fieldnames(newobj))
  warning( sprintf('In duplicating from %s to %s, some fields were ignored', ...
	  old_objname,new_objname) );
end
