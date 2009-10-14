function [subj] = remove_group(subj,objtype,groupname)

% Removes an entire group's worth of objects permanently
%
% [SUBJ] = REMOVE_GROUP(SUBJ,OBJTYPE,GROUPNAME)
%
% Will delete the objects from the SUBJ cell array - NOT RECOMMENDED

% This is part of the Princeton MVPA toolbox, released under the
% GPL. See http://www.csbmb.princeton.edu/mvpa for more
% information.


if ~nargout
  error('Don''t forget to catch the subj structure that gets returned');
end

if nargin~=3
  error('I think you''ve forgotten to feed in all your arguments');
end

members = find_group(subj,objtype,groupname);

if isempty(members)
  error( sprintf('Unable to find a group called %s',groupname) );
end

for m=1:length(members)
  subj = remove_object(subj,objtype,members{m});
end


