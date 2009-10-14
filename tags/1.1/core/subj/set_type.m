function [subj] = set_type(subj,objtype,objcell)

% Replace the entire cell array of this objtype with a new one
%
% [SUBJ] = SET_TYPE(SUBJ,OBJTYPE,OBJCELL)
%
% Recommended for internal use only
%
% See the discussion in the manual about memory efficiency for why
% this isn't an incredibly costly way to do things

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

if ~iscell(objcell)
  error( sprintf('Trying to set %s cell array but it''s not a cell array',objtype) );
end

switch(objtype)
 case 'pattern'
  subj.patterns = objcell;
 case 'regressors'
  subj.regressors = objcell;
 case 'selector'
  subj.selectors = objcell;
 case 'mask'
  subj.masks = objcell;
 
 otherwise
  error('Unknown object type');
end


