function [val] = get_objfield(subj,objtype,objname,fieldname)

% Retrieves a field from an object
%
% [VAL] = GET_FIELD(SUBJ,OBJTYPE,OBJNAME,FIELDNAME)
%
%   e.g. nvox = get_objfield(subj,'mask','wholebrain','nvox');
%
% Use OBJTYPE = 'subj' and OBJNAME = '' if you want to get a field
% in the root of the subj structure itself
%   e.g. header = get_objfield(subj,'subj','','header');

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


if nargin~=4
  error('I think you''ve forgotten to feed in all your arguments');
end

if strcmp(fieldname,'mat')
  error('You should use get_%s to retrieve the mat field',objtype);
end

if strcmp(objtype,'subj')
  obj = subj;
else
  obj = get_object(subj,objtype,objname);
end

if isfield(obj,fieldname)
  val = obj.(fieldname);
else
  error( sprintf('No %s fieldname in %s %s',fieldname,objname,objtype) );
end



