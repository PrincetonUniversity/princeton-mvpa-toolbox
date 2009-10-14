function [subj masknames] = union_masks(subj, newmask, varargin)
% UNION_MASKS - Unions one or more masks together.
%
%  Usage:
%
%    [SUBJ MASKNAMES] = UNION_MASKS(SUBJ, NEWMASK, REGEXP)
%    [SUBJ MASKNAMES] = UNION_MASKS(SUBJ, NEWMASK, MASK1, MASK2, ...)
%
%  This is a wrapper to COMBINE_MASKS with FUNC = @(A,B) A | B, to
%  union masks together. See COMBINE_MASKS for usage information.
%
%  SEE ALSO
%    COMBINE_MASKS, REGEXP, FIND_OBJ_REGEXP

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

[subj masknames] = combine_masks(subj, @(A,B) A | B, newmask, varargin{:});