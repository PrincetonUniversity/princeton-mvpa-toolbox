function [objcell] = get_type(subj,objtype)

% For internal use. Returns the entire cell array of a given type
%
% [OBJCELL] = GET_TYPE(SUBJ,OBJTYPE)

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


objtype = lower(objtype);

% if ~isempty(strmatch(objtype,get_typeslist('plural'),'exact'))
%   error('Use the singular form to refer to the object type');
% end

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

if ~iscell(objcell) && ~isempty(objcell)
  error( sprintf('Unrecoverable error with your entire %s set - should be a cell array',objtype) );
end


