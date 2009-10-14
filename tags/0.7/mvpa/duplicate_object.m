function [subj mat] = duplicate_object(subj,objtype,old_objname,new_objname,varargin)

% Duplicate an object
%
% [SUBJ MAT] = DUPLICATE_OBJECT(SUBJ,OBJTYPE,OLD_OBJNAME,NEW_OBJNAME,...)
%
% Calls init_object to create a new obj called NEW_OBJNAME,
% and then copies across the mat from OLD_OBJNAME and sets
% the derived_from field to OLD_OBJNAME.
%
% Adds the following objects:
% - object
%
% Also copies the appropriate required fields for different object
% types
%
% INCLUDE_UNKNOWN_FIELDS (optional, default = true). By default,
% this will include user-defined fields in the object when
% duplicating. Set this to false if you only want to copy over the
% required fields.
%
% TRANSFER_GROUP_NAME (optional, default = false). By default, the
% NEW_OBJNAME's GROUP_NAME will be set to ''. Set this to true to
% transfer the OLD_OBJNAME's GROUP_NAME too

% This is part of the Princeton MVPA toolbox, released under the
% GPL. See http://www.csbmb.princeton.edu/mvpa for more
% information.


if nargin<4
  error('I think you''ve forgotten to feed in all your arguments');
end

defaults.include_unknown_fields = true;
defaults.transfer_group_name = false;
args = propval(varargin,defaults);

% xxx This check is probably unnecessary???
% if exist_objfield(subj,objtype,old_objname,'movehd')
%   error( sprintf('Unable to duplicate a %s object that has been moved to HD',objtype) );
% end

% Access the object's mat ("Whats your vector, victor?")
mat = get_mat(subj,objtype,old_objname);

% Initialize the new object
subj = init_object(subj,objtype,new_objname);

% Get the old object, change its name, and completely overwrite the
% new object with it. This is a really poor solution, since it will
% overwrite the datetime and the name xxx. See the 'ignored
% fieldnames' error below
if args.include_unknown_fields
  whole_obj = get_object(subj,objtype,old_objname);
  whole_obj.name = new_objname;
  whole_obj.header.history = {};
  whole_obj.created = struct([]); 
  % need to use a subscript on the
  % structure because of a weird matlab syntax thing to do with
  % creating empty structs. there should still only be one 'created'
  % structure
  whole_obj.created(1).datetime = datetime(true);
  whole_obj.last_modified = datetime(true);
  if ~args.transfer_group_name
    whole_obj.group_name = '';
  end
  subj = set_object(subj,objtype,new_objname,whole_obj);
end

% Set the new object's mat to the old object's mat
subj = set_mat(subj,objtype,new_objname,mat);

% Set the derived from field
subj = set_objfield(subj,objtype,new_objname,'derived_from',old_objname);

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
  % xxx this should list which fields were ignored. use the propval
  % compare structs functionality somehow
  %
  % this should have an optional IGNORE flag
  warning( sprintf('In duplicating from %s to %s, some fields were ignored', ...
	  old_objname,new_objname) );
end



