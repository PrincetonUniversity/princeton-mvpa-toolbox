function [subj] = createorupdate_object(subj,objtype,objname,newmat,varargin)

% Creates or updates an object.
%
% If the object doesn't exist, inits the object first.
%
% If the object does already exist, or once it has just been created,
% runs SET_MAT.
%
% You can also set as many fields as you like at the same time - see
% INITSET_OBJECT.m for info on how this works.

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


if nargin<4
  error('Requires at least 4 arguments')
end
if nargout <1
  error('Don''t forget to collected the returned subj');
end

args = propval(varargin,[], ...
	       'ignore_empty_defaults',true, ...
	       'ignore_missing_default',true);

% create it if necessary
if ~exist_object(subj,objtype,objname)
  subj = init_object(subj,objtype,objname);
end

subj = set_mat(subj,objtype,objname,newmat);

% ADD MULTIPLE FIELDS
%
% xxx - this should really be its own function, shared with
% INITSET_OBJECT
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


