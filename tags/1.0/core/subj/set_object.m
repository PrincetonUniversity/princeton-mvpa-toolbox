function [subj] = set_object(subj,objtype,objname,obj)

% Replaces an entire object, i.e. a cell from one of the main 4 cell arrays
%
% [SUBJ] = SET_OBJECT(SUBJ,OBJTYPE,OBJNAME,OBJ)
%
% For internal use. Use set_mat, set_objfield and set_objsubfield

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


if nargin~=4
  error('I think you''ve forgotten to feed in all your arguments');
end

if ~nargout
  error('Don''t forget to catch the subj structure that gets returned');
end

if ~isstruct(obj)
  error( sprintf('You''re about to overwrite the %s %s with a non-struct', ...
	objname,objtype) );
end
  
% Get the entire cell array. Mess with the appropriate cell in
% it. Replace the whole cell array
objcell = get_type(subj,objtype);
objno = get_number(subj,objtype,objname);
objcell{objno} = obj;
subj = set_type(subj,objtype,objcell);
