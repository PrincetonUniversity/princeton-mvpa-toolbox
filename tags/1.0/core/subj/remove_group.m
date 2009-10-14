function [subj] = remove_group(subj,objtype,groupname)

% Removes an entire group's worth of objects permanently
%
% [SUBJ] = REMOVE_GROUP(SUBJ,OBJTYPE,GROUPNAME)
%
% Will delete the objects from the SUBJ cell array - NOT RECOMMENDED

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


