function [perfmet] = perfmet_lda(acts,targs,scratchpad,varargin)

%
% function [perfmet] = perfmet_lda(acts,targs,scratchpad,varargin)
%
% The LDA classifier is considered to guess correctly if its 
% active row (the unit that it guessed) corresponds to the active
% row of the targs (the unit that was desired) using classify from the 
% statistics toolbox of Matlab
%
% ACTS = nUnits x nTimepoints
%
% TARGS = nUnits x nTimepoints
%
% SCRATCHPAD: storing basic results of training and testing LDA functions
%
% ARGS - structure with the following optional arguments
%
% - IGNORE_1OFN (optional, default = false). If your regressors
% aren't boolean, contain rest or contain timepoints with multiple
% active fields, you should be using a more sophisticated
% performance metric. If you're feeling stubborn, and want to use
% this one anyway, set this to true.
%
% Returns a PERFMET struct, which contains the following fields:
%
% - GUESSES = vector indicating which unit was maximally active, i.e. which
% condition the classifier guessed
%
% - DESIREDS = vector indicating unit should have been maximally
% active, i.e. the active condition
%
% - CORRECTS = vector of whether GUESSES == DESIREDS, i.e. whether the
% classifier guessed right
%
% - PERF = scalar, proportion of the time that the classifier was
% correct, i.e. nCorrects/nTimepoints
%
% This perfmet doesn''t deal with ties very well. For that kind of
% situation, you'll need something more sophisticated. To create your
% own perfmet, just make sure your function definition is structured
% the same way as this and that the PERFMET.perf field exists.

% This is part of the Princeton MVPA toolbox, released under the
% GPL. See http://www.csbmb.princeton.edu/mvpa for more
% information.
%
% KN 		ISN Hamburg 01-2007


if ~exist('scratchpad','var')
  scratchpad = [];
end

defaults.ignore_1ofn = false;
args = propval(varargin,defaults);

sanity_check(acts,targs,scratchpad,args);

[nUnits nTimepoints] = size(acts);

[test_max_val test_max_idx]  = max(targs);
test_max_idx(test_max_idx == 1) = 1;
test_max_idx(test_max_idx == 2) = 2;

guesses=acts(1,:);
desireds=test_max_idx;

% Is the index of what you guessed the same as the index of what
% you should have guessed?
corrects = guesses == desireds;

% Need to be able to gracefully deal with the possibility that all
% the timepoints from this run were excluded (i.e. the
% xval timepoints for this run are all 0s). Sanity_check
% will warn if this is the case
if isempty(corrects)
  perf = NaN;
else
  perf = length(find(corrects)) / nTimepoints;
end

perfmet.guesses    = guesses;
perfmet.desireds   = desireds;
perfmet.corrects   = corrects;
perfmet.perf       = perf;
perfmet.scratchpad = [];

%initialising the *msgs cell arrays
errmsgs = {}; 
warnmsgs = {};


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [] = sanity_check(acts,targs,scratchpad,args)

if isempty(acts) && ~isempty(targs)
  error('You have an acts matrix but no targs matrix');
end
if isempty(targs) && ~isempty(acts)
  error('You have a targs matrix but no acts matrix');
end

if isempty(acts) && isempty(targs)
  warning('Acts and targs are empty for this iteration');
end


if ~compare_size(acts,targs)
  error('Can''t calculate performance if acts and targs are different sizes');
end

[isbool isrest isoveractive] = check_1ofn_regressors(targs);
if ~isbool || isrest || isoveractive
  if ~args.ignore_1ofn
    warning('Not 1-of-n regressors');
  end
end

