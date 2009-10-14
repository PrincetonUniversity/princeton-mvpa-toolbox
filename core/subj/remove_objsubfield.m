function [subj] = remove_objsubfield(subj,objtype,objname,fieldname,subfieldname)

% Removes the subfield from an object.
%
% SUBJ = REMOVE_SUBFIELD(SUBJ,OBJTYPE,OBJNAME,FIELDNAME,SUBFIELDNAME)
% 
% See remove_objsubfield for more information

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

field = get_objfield(subj,objtype,objname,fieldname);
field = rmfield(field,subfieldname);
subj = set_objfield(subj,objtype,objname,fieldname,field);

