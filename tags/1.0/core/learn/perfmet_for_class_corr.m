function [perfmet] = perfmet_for_class_corr(acts,targs,scratchpad,args)

% This is the performance metric for the correlation classifier
%
% [PERFMET] = PERFMET_FOR_CLASS_CORR(ACTS,TARGS,SCRATCHPAD,ARGS)
%
% For each test brainstate, find the training brainstate that's
% most similar. The guess is the category of that training
% brainstate. See TRAIN_CORR.M for more information.
%
% Note that this is similar to perfmet_maxclass, in that it
% is finding the single best match for a given test point,
% but it's tailored for use with the correlation-based
% nearest-neighbour classifier (train/test_corr).
%
% ARGS is required by all perfmets, but this function doesn't need
% it, so it should be empty.
%
% ACTS = nUnits x nTrainTimepoints
%
% TARGS = nUnits x nTimepoints

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


if exist('args','var') && ~isempty(args)
  warning('Perfmet_maxclass doesn''t need any args');
end

% WINNING_TEMPLATES = 1 x nTrainTimepoints
% yg holds the max values (of each column) and winning 
% templates holds their indices
[yg winning_templates] = max(acts);

% now we need to know what category it think it is
[max_val guesses]  = max(scratchpad.traintargs(:,winning_templates));

% GUESSES = 1 x nTestTimepoints
[yd desireds] = max(targs);

nTimepoints =size(targs,2);
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

  
