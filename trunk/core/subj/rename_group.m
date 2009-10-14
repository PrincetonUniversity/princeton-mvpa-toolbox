function [subj] = rename_group(subj,objtype,old_groupname,new_groupname,varargin)

% Changes the groupname for all objects in a group
%
% [SUBJ] = RENAME_GROUP(SUBJ,OBJTYPE,OLD_GROUPNAME,NEW_GROUPNAME,...)
%
% This goes through all the objects of a specific type, finds those
% with group_name OLD_GROUPNAME, and sets it instead to
% NEW_GROUP_NAME
%
% RENAME_OBJECTS (optional, default = true). By default,
% this will rename the objects as
% sprintf('%s_%i',new_groupname,memberno). Set this to false
% if you'd like to leave the objects' names as before.

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


defaults.rename_objects = true;
args = propval(varargin,defaults);

if nargin < 4
  error('I think you''ve forgotten to feed in all your arguments');
end

if ~nargout
  error('Don''t forget to catch the subj structure that gets returned');
end

[members isgroup] = find_group_single(subj,objtype,old_groupname);

if ~length(members)
  if ~isgroup
    error('I think you meant to rename an object, rather than a group');
  else
    error('Can''t find a group called %s',old_groupname);
  end
end  

for m=1:length(members)
  subj = set_objfield(subj,objtype,members{m},'group_name',new_groupname);

  if args.rename_objects
    new_objname = sprintf('%s_%i',new_groupname,m);
    subj = rename_object(subj,objtype,members{m},new_objname);
  end
end % m members

