function [subj] = init_object(subj,objtype,new_objname)

% Add a new empty object
%
% [SUBJ] = INIT_OBJECT(SUBJ,OBJTYPE,NEW_OBJNAME);
%
% Update the SUBJ structure by creating a new object of type OBJTYPE
% called NEW_OBJNAME
%
% Adds the following objects:
% - object
%
% This function will initialize everything to empty. If you want to
% base your new object on an existing one, use duplicate_object
% instead.

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


% This looks as though it's very memory-inefficient, but it appears
% that matlab's pretty smart about the way it copies, modifies and passes
% around cell arrays and cells inside them.
%
% If you append a column to a matrix, we think it literally makes a
% copy of the matrix with a larger memory footprint and adds the
% column there. On the other hand, a cell array seems to be just a
% bunch of pointers, so adding cell just means appending a pointer
% without having to make a copy of the contents of the whole cell
% array. There's an ugly demonstration of this in test_mem2, which
% uses the time taken to manipulate very large variables in memory as
% an indication of how much copying is being done.


if nargin~=3
  error('I think you''ve forgotten to feed in all your arguments');
end

if isempty(new_objname)
  error('Can''t create new patterns with empty name');
end

if strcmp(objtype,'subj')
  error('Use init_subj directly. And you can''t store a subj in a subj');
end

if ~isempty(strmatch(new_objname,get_typeslist('single'),'exact'))
  error('It''s a bad idea to name any of your objects of the main types');
end

if ~isempty(find_group(subj,objtype,new_objname))
  error('You can''t create an object if a group with that name already exists');
end

% it would be good to enforce this, but it'll break a lot of other
% code. e.g. we'd need to set INTISET_OBJECT up to be able to call
% this with IGNORE_MASKED_BY
%
% if strcmp(objtype,'pattern')
%   error('Patterns need a MASKED_BY field - use INITSET_OBJECT instead of this function, and then you can associate your new pattern with a mask');
% end

% Initialize what will become our object
obj.name = new_objname;
obj.header.history = [];
obj.mat = [];
obj.matsize = size([]);
obj.group_name = '';
obj.derived_from = '';
obj.header.description = '';
obj.created.datetime = datetime(true);
obj.created.dbstack = dbstack;

% Deal with particular fields that are specific to different types
switch(objtype)
 
 case 'pattern'
  subj.p = new_objname;
  obj.masked_by = '';
  obj.last_modified = [];
  
 case 'regressors'
  subj.r = new_objname;
  obj.condnames = [];
  
 case 'selector'
  subj.s = new_objname;
 
 case 'mask'
  obj.thresh = NaN;
  obj.nvox = NaN;
  obj.last_modified = [];
  
  subj.m = new_objname;
  
end

% In order to work with objects of any type, we're going to get the
% entire cell array for the object and work on that. This way, we
% don't have to refer to subj.patterns or subj.regressors directly
% at all
objcell = get_type(subj,objtype);
nbr_objs = length(objcell);

% Check whether any objs already have this name
for p=1:nbr_objs
  if strcmp(objcell{p}.name,new_objname)
    error( sprintf('Object type %s with name %s already exists',objtype,new_objname) );
  end
end % p nbr_objs

objcell{nbr_objs+1} = obj;

% Now reattach the object to its cell array by overwriting the old
% cell array
subj = set_type(subj,objtype,objcell);


