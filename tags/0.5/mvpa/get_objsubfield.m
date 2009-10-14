function [val] = get_objsubfield(subj,objtype,objname,fieldname,subfieldname)

% Returns the subfield for this object
%
% [VAL] = GET_SUBFIELD(SUBJ,OBJTYPE,OBJNAME,FIELDNAME,SUBFIELDNAME)
%
% For instance, if you wanted to know which function created a
% particular object:
%
%   function_used = get_objsubfield(subj,'pattern','epi_z','creation','function');


if nargin~=5
  error('I think you''ve forgotten to feed in all your arguments');
end

field = get_objfield(subj,objtype,objname,fieldname);

if ~isfield(field,subfieldname)
  error( sprintf('No subfield %s exists in %s field of %s %s', ...
		 subfieldname,fieldname,objname,objtype) );
end

val = field.(subfieldname);

