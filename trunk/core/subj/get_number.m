function [objno] = get_number(subj,objtype,objname,varargin)

% Internal function - find the cell index of an object
%
% OBJNO = GET_NUMBER(SUBJ,OBJTYPE,OBJNAME,...)
%
% % Looks into the subj structure for the object cell called
% OBJNAME and return its index. Returns an error if no
% pattern with this name is found (unless IGNORE_ABSENCE is true).
%
% For internal use only
%
% IGNORE_ABSENCE (optional argument, default = false). By default,
% finding no object with this name causes a fatal error. However, if
% you want to use this to check whether an object of a given name
% exists, set this to true, and then it'll return 0

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


defaults.ignore_absence = false;
args = propval(varargin,defaults);

if ~ischar(objtype) || ~ischar(objname)
  error('Objtype and objname have to be strings');
end

if isempty(objtype) || isempty(objname)
  error('Feeding in empty objtype/name');
end

if ~isempty(strmatch(objname,get_typeslist('single'),'exact'))
  error('It looks as though you''ve inputted an objtype as an objname by accident');
end

objcell = get_type(subj,objtype);

objno = 0;
nbr_objects = length(objcell);

found_already = false;
for p=1:nbr_objects

  % found_already is here so that it can loop through all the cells,
  % and check that none of them have the same name
  if strcmp(objcell{p}.name,objname)
    if ~found_already
      objno = p;
    else
      error( sprintf('You have more than one %s object with the same name',objtype) );
    end
  end
end % p nbr_objects

% Cause an error if we didn''t find the object, unless the user had
% set IGNORE_ABSENCE = true
if ~objno && ~args.ignore_absence
  
  % As a convenience, check to see if there's another object with
  % the right name of a different type, to help the user fix the problem
  type_matches_str = find_obj(subj,objname);
  if ~isempty(type_matches_str)
    disp( sprintf('You asked for a %s object called %s. Did you mean one of these objtypes?%s',objtype,objname,type_matches_str) );
  end
  error(sprintf('No %s objects called %s',objtype,objname));
end



