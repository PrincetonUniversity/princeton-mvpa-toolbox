function [subj] = rename_object(subj,objtype,old_objname,new_objname)

% Rename an object OLD_OBJNAME TO NEW_OBJNAME
%
% [subj] = rename_object(subj,objtype,old_objname,new_objname)
%
% Note: this could cause friction in your scripts, if you've
% forgotten to update the new name later. Also, other parts of the
% toolbox could refer to this object, and they will not have been
% updated. Overall, renaming objects is not a great idea
%
% It would be nice to search through all the 'derived_from' fields
% and change any references to reflect the new name etc.

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


if ~exist_object(subj,objtype,old_objname)
  error('The object you''re trying to rename doesn''t exist');
end

if exist_object(subj,objtype,new_objname)
  err = sprintf('There is already a %s object called %s',objtype,new_objname);
  error(err);
end

if exist_group(subj,objtype,new_objname)
  err = sprintf('There is already a %s group called %s',objtype,new_objname);
  error(err);
end

% Can't use SET_OBJFIELD to change the name, because it has been
% designed not to let you

obj = get_object(subj,objtype,old_objname);
obj.name = new_objname;
subj = set_object(subj,objtype,old_objname,obj);

% keep a record of what it used to be called
subj = set_objfield(subj,objtype,new_objname, ...
                         'renamed_from',old_objname, ...
                         'ignore_absence',true);

disp( sprintf('Renamed %s %s to %s',objtype,old_objname,new_objname) );



