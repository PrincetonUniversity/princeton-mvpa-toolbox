function [subj results] = load_subj(fn)

% Loads in a SUBJ structure
%
% [SUBJ] = LOAD_SUBJ([FN])
%
% This is the complement to SAVE_SUBJ.M. It's very simple indeed
%
% FN (optional, default = 'subj')


if ~exist('fn')
  fn = 'subj';
end

subj = [];
results = [];

load(fn);





