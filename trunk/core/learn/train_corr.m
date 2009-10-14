function [scratchpad] = train_corr(trainpats,traintargs,in_args,cv_args)

% Correlation-based classifier
%
% [SCRATCHPAD] = TRAIN_CORR(TRAINPATS,TRAINTARGS,IN_ARGS,CV_ARGS)
%
% See the related TEST_CORR function that gets called
% afterwards to assess how well this generalizes to the test
% data.
%
% Doesn't calculate its performance. Just spits out the
% activations
%
% PATS = nFeatures x nTimepoints
% TARGS = nOuts x nTimepoints
%
% SCRATCHPAD will contain all the other information that you
% might need when analysing the network's output, most of
% which is specific to each particular classifier.
%
% IN_ARGS can contain the following fields optionally:
%
% DIST_METRIC (optional, default = 'corr'). This is the
% distance metric used to assess similarity. In the future,
% we should try and set things up so that any of the pdist
% distance metrics are supported, and that user-defined
% algorithms that fit in that mold can be used too. xxx

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


defaults.dist_metric = 'corr';
args = propval(in_args,defaults);
scratchpad.class_args = args;

sanity_check(trainpats,traintargs,args);

% this doesn't actually have a training phase
% but we do need to store the trainpats and traintargs in the
% scratchpad so TEST_CORR.M can use them later
scratchpad.trainpats = trainpats;
scratchpad.traintargs = traintargs;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [] = sanity_check(trainpats,traintargs,scratchpad,args)

[isbool isrest isoveractive] = check_1ofn_regressors(traintargs);
if ~isbool || isrest || isoveractive
  warning('Not 1-of-n regressors');
end

if size(trainpats,2)==1
  error('Can''t classify a single timepoint');
end

if size(trainpats,2) ~= size(traintargs,2)
  error('Different number of training pats and targs timepoints');
end

