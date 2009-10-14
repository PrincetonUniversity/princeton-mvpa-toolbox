function [subj results] = load_subj(fn)

% Loads in a SUBJ structure
%
% [SUBJ] = LOAD_SUBJ([FN])
%
% This is the complement to SAVE_SUBJ.M. It's very simple indeed
%
% FN (optional, default = 'subj')

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


if ~exist('fn')
  fn = 'subj';
end

subj = [];
results = [];

load(fn);





