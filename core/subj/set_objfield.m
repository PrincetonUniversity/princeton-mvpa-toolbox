function [subj] = set_objfield(subj,objtype,objname,fieldname,newval,varargin)

% Replace or add a field to an object
%
% [SUBJ] = SET_OBJFIELD(SUBJ,OBJTYPE,OBJNAME,FIELDNAME,NEWVAL,...)
%
% Replaces/adds the FIELDNAME field in OBJNAME object of type OBJTYPE
% with NEWVAL. Will create the field if it doesn't exist, but will
% warn you unless you set IGNORE_ABSENCE = true
%
% IGNORE_ABSENCE (optional, default = false). By default, this will
% warn you if the field you're about to set doesn't already
% exist. Set to true if you're sure that's ok
%
% IGNORE_EMPTY (optional, default = false). By default, this will
% warn you if the field you're about to set is empty (and is
% overwriting a full one). Set to true if you're sure you want to
% do that
%
% IGNORE_CREATED (optional, default = false). By default, this will
% error if you try and set the 'created' field, but if this is
% true, then it continues as normal.

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


% This looks long, but it's basically just:
%   get_object
%   obj.(fieldname) = newval
%   set_object


if ~nargout
  error('Don''t forget to catch the subj structure that gets returned');
end

defaults.ignore_absence = false;
defaults.ignore_empty = false;
defaults.ignore_created = false;
args = propval(varargin,defaults);

% If setting a field in the root of the SUBJ structure, deal with that
% separately here
if strcmp(objtype,'subj')
  if ~isfield(subj,fieldname) && ~args.ignore_absence
    warn_str = sprintf('No subj field called %s - creating it',fieldname);
    warning( warn_str );
    subj.(fieldname) = [];
  end
  subj.(fieldname) = newval;
  return
end

% Otherwise, get the object from the SUBJ structure
obj = get_object(subj,objtype,objname);

% Error-checking
switch(fieldname)
 case 'name'
  error('Use ''rename_object'' to rename an object');
 case 'mat'
  error('You should use set_%s to retrieve the mat field',objtype);
 case 'history'
  error('You should use add_%s_history to add to the history',objtype);
 case 'created'
  if ~args.ignore_created
    error('You should use add_created to add information about the object''s creation');
  end
end

if ~isfield(obj,fieldname)
  if ~args.ignore_absence
    % If you're setting a field that doesn't exist, warn the user
    % (unless IGNORE_ABSENCE) in order to highlight possible typos
    warn_str = sprintf('No field in %s %s called %s - creating it', ...
		       objname,objtype,fieldname);
    warning( warn_str );
  end
  obj.(fieldname) = [];
end

if isempty(newval) && ~args.ignore_empty && ~isempty(obj.(fieldname))
  warning('About to overwrite %s''s %s field with an empty one',objname,fieldname);
end

% Set the field in the object, and then set the object in the SUBJ
% structure
obj.(fieldname) = newval;
subj = set_object(subj,objtype,objname,obj);



