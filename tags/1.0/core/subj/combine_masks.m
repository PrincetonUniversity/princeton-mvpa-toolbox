function [subj masknames] = combine_masks(subj, func, newmask, varargin)
% Combines two masks together using a given function.
%
% Usage:
%
%  [SUBJ] = COMBINE_MASKS(SUBJ, FUNC, NEWMASK, MASK1, MASK2, ...)
%  [SUBJ MASKNAMES] = COMBINE_MASKS(SUBJ, FUNC, NEWMASK, REGEXP)
%
%  Combines either a list of masks or all masks matching a given
%  regular expression REGEXP using the function provided FUNC. FUNC
%  must take two arguments only. For example, to AND masks together,
%  use @(A,B) A & B.
%
%  If more than two masks are specified, COMBINE_MASKS will
%  iteratively apply FUNC as follows: FUNC(FUNC(N-1,N-2),N). In
%  other words, COMBINE_MASKS can be used to take the combined
%  union or intersection of an unlimited number of masks.
%
%  The result of all operations is saved in a new mask named NEWMASK.
%
%  Returns the modified subject structure SUBJ and a cell array of
%  all masks combined in this fashion.
%
%  SEE ALSO
%    UNION_MASKS, REGEXP, FIND_OBJ_REGEXP

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

[func funcstr] = arg2funct(func);

masknames = {};

% Usage: regex of which masks to union
if nargin == 4
  % Get a list of mask names to search from the subject structure
  masknames = find_obj_regexp(subj, 'mask', varargin{1});
    
else % User provided a list of masks  
  masknames = varargin;  
end

dispf('Combining %d masks using operation: ''%s''', ...
      numel(masknames), funcstr);

mask = [];
for i = 1:numel(masknames)
  
  if isempty(mask)
    mask = get_mat(subj, 'mask', masknames{i});
  else
    mask = func(mask, get_mat(subj, 'mask', masknames{i}));
  end
  
end

subj = initset_object(subj, 'mask', newmask, mask);
  