function [newpat] = apply_filt(pat, varargin)

% Filter the run of a pattern.
%
% [NEWPAT] = APPLY_FILT(PAT, ...)
%
% Used in conjuction with apply_to_runs.m.
%
% Arguments:
%
% FILT (optional) the filter to be used.  If none is provided, the
% default is a box filter of size 3.

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

% default filter: box filter of size 3
defaults.filt = ones(1,3) ./ 3;

args = propval(varargin, defaults, 'ignore_missing_default', true);

newpat = zeros(size(pat));

% filter each voxel individually
for v = 1:size(pat, 1)    
  newpat(v, :) = filter(args.filt, 1, pat(v,:));
end

