function [name obj] = get_name(subj,objtype,objno)

% Internal function - gets the object's name from its cell index
%
% [NAME OBJ] = GET_NAME(SUBJ,OBJTYPE,OBJNO)
%
% Returns the name of an object if all you know is its number. Avoids
% directly accessing the subj structure
%
% Useful if you're looping over all the members of a group, for
% instance

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


if nargin~=3
  error('I think you''ve forgotten to feed in all your arguments');
end

objcell = get_type(subj,objtype);
obj = objcell{objno};
name = obj.name;

