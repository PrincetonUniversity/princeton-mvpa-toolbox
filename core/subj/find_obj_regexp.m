function [ matches ] = find_obj_regexp(subj, objtype, expr)
% FIND_OBJ_REGEXP - Searches for objects using regular expressions.
%
% Usage:
%
%  [ MATCHES ] = FIND_OBJ_REGEXP(SUBJ, OBJTYPE, EXPR)
% 
% Searches through the SUBJ structure to find objects of type
% OBJTYPE whose name matches the regular expression in string EXPR.
% Matches are returned in the cell array MATCHES.
%  
% SEE ALSO
%   FIND_OBJ, REGEXP

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

matches = {};

numObjects = 0;
if strcmp(objtype, 'selector')
  numObjects = numel(subj.selectors);
elseif strcmp(objtype, 'regressors')
  numObjects = numel(subj.regressors);  
elseif strcmp(objtype, 'pattern')
  numObjects = numel(subj.patterns);
elseif strcmp(objtype, 'mask')
  numObjects = numel(subj.masks);
else
  error('Unrecognized object type');
end

for i = 1:numObjects
  
  name = get_name(subj, objtype, i);
  if regexp(name, expr)
    matches = {matches{:} name};
  end
  
end

if numel(matches) == 1
  matches = matches{1};
end
