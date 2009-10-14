function [newpat] = apply_zscore(pat, varargin)

% Z-score a pattern.
%
% [NEWPAT] = APPLY_ZSCORE(PAT, ...)
%
% Used in conjuction with apply_to_runs.m.  Z-scores a given
% pattern.
%
% Arguments:
%
% USE_MVPA_VER (optional, default = false) Use the MVPA toolbox's
% zscoring instead of Mathworks, if you lack the statistics toolbox.

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

defaults.use_mvpa_ver = false;

args = propval(varargin, defaults, 'ignore_missing_default', true);

fname = 'zscore';

if (args.use_mvpa_ver)
  fname = 'zscore_mvpa';
end

zhandle = str2func(fname);

% double transpose because zscore doesn't let you specify axis
newpat = zhandle(pat')';
