function [subj] = set_objsubfield(subj,objtype,objname,fieldname,subfieldname,newval,varargin)

% Sets the subfield of the object to NEWVAL.
%
% [SUBJ] = SET_OBJSUBFIELD(SUBJ,OBJTYPE,OBJNAME,FIELDNAME,SUBFIELDNAME,NEWVAL,...)
%
% Works very similarly to SET_OBJFIELD.
%
% For instance, the DESCRIPTION of an object is stored in its
% HEADER.DESCRIPTION. To modify it:
%
%    subj = set_objfield(subj,'pattern','raw','header','description', ...
%                          'This contains my raw data');
%
% Use the optional IGNORE_ABSENCE and IGNORE_EMPTY flags like
% SET_OBJFIELD to avoid warnings

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


if ~nargout
  error('Don''t forget to catch the subj structure that gets returned');
end

defaults.ignore_absence = false;
defaults.ignore_empty = false;
args = propval(varargin,defaults);

% Create the main field if it doesn't already exist
% This will deservedly trigger a warning in SET_FIELD
if ~exist_objfield(subj,objtype,objname,fieldname)
  subj = set_objfield(subj,objtype,objname,fieldname,[]);
end

field = get_objfield(subj,objtype,objname,fieldname);

% Warnings
if ~isfield(field,subfieldname) && ~args.ignore_absence
  warn_str = sprintf('No subfield %s in %s in %s %s - creating subfield', ...
		     subfieldname,fieldname,objname,objtype);
  warning(warn_str);
  field.(subfieldname) = [];
end
if isempty(newval) & ~args.ignore_empty && ~isempty(field.(subfieldname))
  warning('About to overwrite a subfield with an empty one');
end

field.(subfieldname) = newval;

subj = set_objfield(subj,objtype,objname,fieldname,field);


