function [subj] = initset_object(subj,objtype,objname,newmat,varargin)

% Calls init_object then set_mat (and set_objfield optionally)
%
% [SUBJ] = INITSET_OBJECT(SUBJ,OBJTYPE,OBJNAME,NEWMAT,...)
%
% This is for lazy people who want to init their object and then
% put the mat inside it, all in one go
%
% You can also set as many fields as you like at the same time. If
% they don't already exist, they will be created. Just add propval
% pairs as normal as a cell array in the varargin for fieldname +
% value, e.g.
%
% subj = initset_object(subj,'pattern','epi',mypat,'masked_by','wholebrain');
%
% Note: you won't get a warning if adding a field that doesn't
% already exist, so be careful to type your fieldnames
% correctly
%
% See also: createorupdate_object.m

% license:
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


if nargin<4
  error('Requires at least 4 arguments')
end
if nargout <1
  error('Don''t forget to collected the returned subj');
end

args = propval(varargin,[], ...
	       'ignore_empty_defaults',true, ...
	       'ignore_missing_default',true);

subj = init_object(subj,objtype,objname);

subj = set_mat(subj,objtype,objname,newmat);

% ADD MULTIPLE FIELDS
%
% xxx - this should really be its own function, so that
% CREATEORUPDATE_OBJECT can use it too
fields = fieldnames(args);

for f=1:length(fields)
  curfield = fields{f};
  curval = args.(curfield);
  
  if strcmp(curfield,'created')
    subj = add_created(subj,objtype,objname,curval);
  else
    subj = set_objfield(subj,objtype,objname,curfield,curval, ...
                             'ignore_absence',true);
  end
end % f

% make sure you can't create a pattern without a
% masked_by field
if strcmp(objtype,'pattern')
  masked_by_match = strmatch('masked_by',fields);
  if isempty(masked_by_match)
    error('You have to set the ''masked_by'' field when creating a pattern');
  end
  if ~exist_object(subj,'mask',args.masked_by)
    error('The mask specified in ''masked_by'' doesn''t exist');
  end
end
