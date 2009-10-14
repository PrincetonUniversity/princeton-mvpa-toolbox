function [perfmet] = perfmet_maxclass(acts,targs,args)

% This is the most basic performance metric.
%
% [PERFMET] = PERFMET_MAXCLASS(ACTS,TARGS,ARGS)
%
% The classifier is considered to guess correctly if its maximally
% active row (the unit that it guessed) corresponds to the most active
% row of the targs (the unit that was desired)

%
% ARGS is required by all perfmets, but this function doesn't need
% it, so it should be empty.
%
% ACTS = nUnits x nTimepoints
%
% TARGS = nUnits x nTimepoints
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


if exist('args','var') & ~isempty(args)
  warning('Perfmet_maxclass doesn''t need any args');
end

if ~compare_size(acts,targs)
  error('Can''t calculate performance if acts and targs are different sizes');
end

[nUnits nTimepoints] = size(acts);

[y guesses] = max(acts);

[y desireds] = max(targs);

corrects = guesses == desireds;

perf = length(find(corrects)) / nTimepoints;

perfmet.guesses    = guesses;
perfmet.desireds   = desireds;
perfmet.corrects   = corrects;
perfmet.perf       = perf;
perfmet.scratchpad = [];
