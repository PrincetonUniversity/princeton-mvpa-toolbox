function [matches] = find_group(subj,objtype,groupname)

% Returns a list of names of objects from this group
%
% [MATCHES] = FIND_GROUP(SUBJ,OBJTYPE,GROUPNAME)
%
% Returns a cell array of the names of all objects within SUBJ of
% OBJTYPE object type that belong to group GROUPNAME
%
% Returns no names if groupname is empty


if nargin~=3
  error('I think you''ve forgotten to feed in all your arguments');
end

matches = {};

if isempty(groupname)
  return
end

objcell = get_type(subj,objtype);
nbr_objects = length(objcell);

for i=1:nbr_objects
  if strmatch(objcell{i}.group_name,groupname,'exact')
    matches{end+1} = objcell{i}.name;
  end
end


