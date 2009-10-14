function [objcell] = get_type(subj,objtype)

% For internal use. Returns the entire cell array of a given type
%
% [OBJCELL] = GET_TYPE(SUBJ,OBJTYPE)


% Check to see whether the type has been inputted as upper-case
if isempty(strmatch(lower(objtype),objtype,'exact'))
  error('Use lower-case to refer to the objtype');
end

switch(objtype)
 case 'pattern'
  objcell = subj.patterns;
 case 'regressors'
  objcell = subj.regressors;
 case 'selector'
  objcell = subj.selectors;
 case 'mask'
  objcell = subj.masks;

 case 'subj'
  error('You''ve tried to get an objtype called ''subj'' - doesn''t make sense');

 otherwise
  error('Unknown object type');
end

if ~iscell(objcell) & ~isempty(objcell)
  error( sprintf('Unrecoverable error with your entire %s set - should be a cell array',objtype) );
end


