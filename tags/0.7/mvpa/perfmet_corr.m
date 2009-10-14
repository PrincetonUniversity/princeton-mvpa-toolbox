function [perfmet] = perfmet_corr(acts,targs,scratchpad,args)

% This is the performance metric for the correlation classifier
%
% [PERFMET] = PERFMET_CORR(ACTS,TARGS,SCRATCHPAD,ARGS)
%
% For each test brainstate, find the training brainstate that's
% most similar. The guess is the category of that training
% brainstate. See TRAIN_CORR.M for more information.
%
% ARGS is required by all perfmets, but this function doesn't need
% it, so it should be empty.
%
% ACTS = nUnits x nTrainTimepoints
%
% TARGS = nUnits x nTimepoints

% This is part of the Princeton MVPA toolbox, released under the
% GPL. See http://www.csbmb.princeton.edu/mvpa for more
% information.


if exist('args','var') && ~isempty(args)
  warning('Perfmet_maxclass doesn''t need any args');
end

% WINNING_TEMPLATES = 1 x nTrainTimepoints
[yg winning_templates] = max(acts);

% GUESSES = 1 x nTestTimepoints
[yd desireds] = max(targs);

disp('In perfmet_corr');
keyboard


corrects = guesses == desireds;

perf = length(find(corrects)) / nTimepoints;

perfmet.guesses    = guesses;
perfmet.desireds   = desireds;
perfmet.corrects   = corrects;
perfmet.perf       = perf;
perfmet.scratchpad = [];



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [] = sanity_check(trainpats,traintargs,testpats,testtargs)

if ( ...
    ~strcmp(scratchpad.class_args.train_funct_name,'train_corr') || ...
    ~strcmp(scratchpad.class_args.test_funct_name,'test_corr') ...
    )
  error('Need to be used with train_ and test_ corr');
end

  
