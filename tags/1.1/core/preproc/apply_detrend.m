function [newpat] = apply_detrend(pat, varargin)

% Detrend a pattern.
%
% [NEWPAT] = APPLY_DETREND(PAT, ...)
%
% Detrends a pattern.  Used in conjunction with apply_to_runs.m.

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

newpat = detrend(pat);

