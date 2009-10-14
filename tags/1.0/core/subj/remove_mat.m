function [subj] = remove_mat(subj,objtype,objname)

% Sets the mat field of the OBJNAME of OBJTYPE to empty.
%
% [SUBJ] = REMOVE_MAT(SUBJ,OBJTYPE,OBJNAME)
%
% N.B. This doesn't change the subj.x strings. If subj.x refers to
% the object that was just removed, remember to update subj.x
% accordingly.

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

if nargin~=3
  error('I think you''ve forgotten to feed in all your arguments');
end

subj = set_mat(subj,objtype,objname,[],'ignore_empty',true);
