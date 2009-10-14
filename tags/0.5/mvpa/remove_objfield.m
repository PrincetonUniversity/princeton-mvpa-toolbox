function [subj] = remove_objfield(subj,objtype,objname,fieldname)

% Removes a field from the object
%
% [SUBJ] = REMOVE_OBJFIELD(SUBJ,OBJTYPE,OBJNAME,FIELDNAME)
%
% If OBJTYPE == 'subj', removes a field from the SUBJ root. Can't
% be used to delete any of the main types or any required fields


if ~nargout
  error('Don''t forget to catch the subj structure that gets returned');
end

if nargin~=4
  error('I think you''ve forgotten to feed in all your arguments');
end

if strcmp(objtype,'subj')
  % If the user is trying to remove one of the main types,
  % e.g. OBJTYPE == 'subj' and FIELDNAME == 'pattern'
  if ~isempty(strmatch(fieldname,get_typeslist('plurals'),'exact'))
    error('Can''t remove one of the main data types');
  end
  subj = rmfield(subj,fieldname);
  return
end

% Refuse to remove any of the required fields
% There should be a get_special_fields function to retrieve these xxx
barred_fields = {'name','header','mat','group_name', ...
		 'matsize','derived_from','created', ...
		 'nvox','masked_by','cond_names','thresh');
if ~isempty(strmatch(barred_fields,fieldname,'exact'))
  error('Unable to delete a required field');
end

% Field doesn't exist
if ~exist_objfield(subj,objtype,objname,fieldname)
  error( sprintf('Unable to remove %s from %s %s because it doesn''t exist', ...
		 fieldname,objname,objtype) );
end

% Actually delete the field
obj = get_object(subj,objtype,objname);
obj = rmfield(obj,fieldname);
subj = set_object(subj,objtype,objname,obj);

