function [isthere] = exist_objsubfield(subj,objtype,objname,fieldname,subfieldname)

% Checks whether the subfield exists
%
% [ISTHERE] = EXIST_SUBFIELD(SUBJ,OBJTYPE,OBJNAME,FIELDNAME,SUBFIELDNAME)
%
% Checks whether the SUBFIELDNAME exists inside the FIELD of the
% object OBJNAME of OBJTYPE.
%
% Returns true if it does, else false.


obj = get_object(subj,objtype,objname);

if ~isfield(objname,fieldname)
  isthere = false;
  warning('The field itself doesn''t exist, let alone the subfield');
  return
end

if isfield(objname.(fieldname),subfieldname)
  isthere = true;
else
  isthere = false;
end
