function [perfmet] = perfmet_maxclass_ignore_rest(acts,targs,scratchpad,varargin)

% Like PERFMET_MAXCLASS but ignores rest timepoints.
%
% [PERFMET] = PERFMET_MAXCLASS_IGNORE_REST(ACTS,TARGS,SCRATCHPAD,...)
%
% Standard PERFMEX_MAXCLASS considers a guess to be correct
% if its maximally active row (the unit that it guessed)
% corresponds to the most active row of the targs (the unit
% that was desired). Unfortunately, this mistreats rest
% timepoints (i.e. when the regressors are all zero).
%
% This sets the CORRECTS for any timepoints whose DESIREDS
% are all zero to NaN (and ignores them when calculating the
% mean perf).

% This is part of the Princeton MVPA toolbox, released under the
% GPL. See http://www.csbmb.princeton.edu/mvpa for more
% information.


if ~exist('scratchpad','var')
  scratchpad = [];
end

sanity_check(acts,targs,scratchpad);

[nUnits nTimepoints] = size(acts);

[yg guesses] = max(acts);

[yd desireds] = max(targs);
% the MAX function returns the first item's index in a tie,
% so if the TARGS for a timepoint are all-zeros, it'll tell
% you desired=1
%
% to correct this, we're going to reset any of those rest
% timepoints to zeros in the DESIREDS
desireds(~sum(targs)) = 0;


% Is the index of what you guessed the same as the index of what
% you should have guessed?
corrects = guesses == desireds;
% we need CORRECTS to be double so that it can include NaNs
corrects = double(corrects);

% any timepoints whose DESIREDS are all zero don't get counted
corrects(~desireds) = NaN;

% Need to be able to gracefully deal with the possibility that all
% the timepoints from this run were excluded (i.e. the
% xval timepoints for this run are all 0s). Sanity_check
% will warn if this is the case
if isempty(corrects)
  perf = NaN;
else
  perf = mean_ignore_nans(corrects);
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
function [] = sanity_check(acts,targs,scratchpad)

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

% not checking 1 of n regressors. the idea is that this is
% supposed to be more robust than PERFMET_MEXCLASS to
% complicated regressors

