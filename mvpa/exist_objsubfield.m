function [isthere] = exist_objsubfield(subj,objtype,objname,fieldname,subfieldname)

% Checks whether the subfield exists
%
% [ISTHERE] = EXIST_SUBFIELD(SUBJ,OBJTYPE,OBJNAME,FIELDNAME,SUBFIELDNAME)
%
% Checks whether the SUBFIELDNAME exists inside the FIELD of the
% object OBJNAME of OBJTYPE.
%
% Returns true if it does, else false.

% This is part of the Princeton MVPA toolbox, released under the
% GPL. See http://www.csbmb.princeton.edu/mvpa for more
% information.


obj = get_object(subj,objtype,objname);

if ~isfield(obj,fieldname)
  isthere = false;
  warning('The field itself doesn''t exist, let alone the subfield');
  return
end

if isfield(obj.(fieldname),subfieldname)
  isthere = true;
else
  isthere = false;
end
