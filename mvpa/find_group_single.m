function [names isgroup] = find_group_single(subj,objtype,name,varargin)

% Lets you know whether you have an objname or groupname
%
% [NAMES ISGROUP] = FIND_GROUP_SINGLE(SUBJ,OBJTYPE,NAME,...)
%
% REPMAT_TIMES (optional, default = 1). By default, this
% will return just a single cell containing the name of the object
% if NAME is an object. However, if REPMAT_TIMES is true, then
% it will tile this name N times


defaults.repmat_times = 1;
args = propval(varargin,defaults);

if ~isnumeric(args.repmat_times)
  error('repmat_times must be a number');
end

if ~ischar(name)
  error('Your object/group name must be a string');
end

members = find_group(subj,objtype,name);
if isempty(members)
  isgroup = false;
else
  isgroup = true;
end

if exist_object(subj,objtype,name)
  isobject = true;
  objname = name;
else
  isobject = false;
end

if isgroup & isobject
  error( sprintf('Both an object and a group called %s exist',name) );
end

if ~isgroup & ~isobject
  error( sprintf('There are no groups or objects called %s',name) );
end

if isgroup
  names = members;
else
  names = repmat({objname},args.repmat_times,1);
end

