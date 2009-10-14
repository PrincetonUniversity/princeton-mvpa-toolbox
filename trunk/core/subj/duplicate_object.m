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
% Even if the old object had been moved to the HD, the new object will
% still be stored in RAM.
%
% INCLUDE_UNKNOWN_FIELDS (optional, default = true). By default,
% this will include user-defined fields in the object when
% duplicating. Set this to false if you only want to copy over the
% required fields.
%
% TRANSFER_GROUP_NAME (optional, default = false). By default, the
% NEW_OBJNAME's GROUP_NAME will be set to ''. Set this to true to
% transfer the OLD_OBJNAME's GROUP_NAME too

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


% if ~nargout
%   error('Don''t forget to catch the subj structure that gets returned');
% end

if nargin<4
  error('I think you''ve forgotten to feed in all your arguments');
end

defaults.include_unknown_fields = true;
defaults.transfer_group_name = false;
args = propval(varargin,defaults);

% Initialize the new object
subj = init_object(subj,objtype,new_objname);

if ~args.include_unknown_fields
  error(['Including unknown fields is now required - you''ll have to' ...
	 ' delete them afterwards yourself']);
end

% Get the old object, change its name, and completely overwrite the
% new object with it. This is the simplest solution if we want to
% ensure we get all the fields from the old object, though we have
% to deal with objects that have been moved to HD specially
% below. We also have to take special care of the creation and
% modification date
whole_obj = get_object(subj,objtype,old_objname);
whole_obj.name = new_objname;
whole_obj.header.history = {};

% need to use a subscript on the
% structure because of a weird matlab syntax thing to do with
% creating empty structs. there should still only be one 'created'
% structure
whole_obj.created.datetime = datetime(true);
whole_obj.last_modified = [];
if ~args.transfer_group_name
  whole_obj.group_name = '';
end
subj = set_object(subj,objtype,new_objname,whole_obj);

% Access the object's mat ("Whats your vector, victor?")
mat = get_mat(subj,objtype,old_objname);

% If the old object was stored on the hard disk, then the direct
% object copy will only copy an empty MAT field, so we need to
% explicitly get the MAT (which will load it from the HD
% transparently), and set it. Importantly, we need to get rid of the
% MOVEHD field first, otherwise SET_MAT will write the new MAT over
% the old object's file.
if exist_objfield(subj,objtype,new_objname,'movehd')
  subj = remove_objfield(subj,objtype,new_objname,'movehd');

  % Copy the old object's mat to the new object - best to do this
  % separately in case 
  subj = set_mat(subj,objtype,new_objname,mat);
end

% Set the derived_from field
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



