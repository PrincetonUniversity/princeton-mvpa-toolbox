function [subj] = remove_mat(subj,objtype,objname)

% Sets the mat field of the OBJNAME of OBJTYPE to empty.
%
% [SUBJ] = REMOVE_MAT(SUBJ,OBJTYPE,OBJNAME)
%
% N.B. This doesn't change the subj.x strings. If subj.x refers to
% the object that was just removed, remember to update subj.x
% accordingly.

% This is part of the Princeton MVPA toolbox, released under the
% GPL. See http://www.csbmb.princeton.edu/mvpa for more
% information.


if ~nargout
  error('Don''t forget to catch the subj structure that gets returned');
end

if nargin~=3
  error('I think you''ve forgotten to feed in all your arguments');
end

subj = set_mat(subj,objtype,objname,[],'ignore_empty',true);
