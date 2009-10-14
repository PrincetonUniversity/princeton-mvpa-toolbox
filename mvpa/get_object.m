function [obj] = get_object(subj,objtype,objname)

% Return the entire object.
%
% [OBJ] = GET_OBJECT(SUBJ,OBJTYPE,OBJNAME)
%
% Can often be useful for peering inside a particular object. For
% instance, to view its innards of a pattern called 'epi_z', just
% type:
%
%   get_object(subj,'pattern','epi_z')
%
% Technical note: You can also set OBJTYPE to 'subj', and return the
% subj structure itself back. This is useful for scripts that access
% the header


if nargin~=3
  error('I think you''ve forgotten to feed in all your arguments');
end

if strcmp(objtype,'subj')
  obj = subj;
  return
end

objcell = get_type(subj,objtype);
objno = get_number(subj,objtype,objname);
obj = objcell{objno};
