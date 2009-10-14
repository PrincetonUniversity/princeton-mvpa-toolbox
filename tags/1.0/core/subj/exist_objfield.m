function [isthere] = exist_objfield(subj,objtype,objname,fieldname)

% Checks whether the field exists
%
% [ISTHERE] = EXIST_FIELD(SUBJ,OBJTYPE,OBJNAME,FIELDNAME)
%
% Checks whether the FIELDNAME exists inside the object OBJNAME of
% OBJTYPE.
%
% Returns true if it does, else false.

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


obj = get_object(subj,objtype,objname);

if isfield(obj,fieldname)
  isthere = true;
else
  isthere = false;
end

