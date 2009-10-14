function [fields] = get_special_fields_list(objtype)

% Internal - gets a list of special fieldnames
%
% [SPECIAL_FIELDS_LIST] = GET_SPECIAL_FIELDS_LIST([OBJTYPE])
%
% Returns a cell array of field names that you can't remove or mess
% with.
%
% OBJTYPE (optional, default = ''). If this empty, returns the
% common required fields. If set to a recognised object type,
% also returns the required fields for that object

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


fields = {'name', ...
	  'header', ...
	  'mat', ...
	  'group_name', ...
	  'matsize', ...
	  'derived_from', ...
	  'created'};

switch(objtype)
 case ''
 case 'pattern'
  fields{end+1} = 'masked_by';
 case 'regressors'
  fields{end+1} = 'condnames';
 case 'selector'
 case 'mask'
  fields{end+1} = 'nvox';
  fields{end+1} = 'thresh';
 otherwise
  warning('Unknown objtype to get fields for');
end

