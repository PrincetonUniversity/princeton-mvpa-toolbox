function [matches] = find_group(subj,objtype,groupname)

% Returns a list of names of objects from this group
%
% [MATCHES] = FIND_GROUP(SUBJ,OBJTYPE,GROUPNAME)
%
% Returns a cell array of the names of all objects within SUBJ of
% OBJTYPE object type that belong to group GROUPNAME
%
% Returns no names if groupname is empty

% This is part of the Princeton MVPA toolbox, released under the
% GPL. See http://www.csbmb.princeton.edu/mvpa for more
% information.


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
  if strcmp(objcell{i}.group_name,groupname)
    matches{end+1} = objcell{i}.name;
  end
end


