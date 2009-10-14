function [acts scratchpad] = test_corr(testpats,testtargs,scratchpad)

% Correlation-based classifier testing
%
% [ACTS SCRATCHPAD] = TEST_CORR(TESTPATS,TESTTARGS,SCRATCHPAD)
%
% This is the main function for the correlation-based classifier, akin
% in spirit to the one used in Haxby (2001). It compares each test
% brainstate to all of its 'template' brainstates from training. The
% classifier's guess is simply the category of the training brainstate
% that is most similar.

% Requires you to have run TRAIN_CORR.M first, in order to have the
% trainpats and traintargs set up in the scratchpad.
%
% See also: TRAIN_CORR.M
%
% ACTS is an nOuts x nTestTimepoints matrix that contains the
% correlation matrix
%
% Does this amount to a simple correlation KNN??? xxx


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


trainpats = scratchpad.trainpats;
traintargs = scratchpad.traintargs;

sanity_check(trainpats,traintargs,testpats,testtargs);

[r p] = corr(trainpats,testpats);
scratchpad.r = r;
scratchpad.p = p;

%%% test generalization performance on the test data

%%% save the activations into ACTS (nOuts x nTestTimepoints)
acts = r;

%%% add to the scratchpad if there's anything new to say

% maybe remove the trainpats and traintargs from the scratchpad
% after we're done?



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [] = sanity_check(trainpats,traintargs,testpats,testtargs)

[isbool isrest isoveractive] = check_1ofn_regressors(testtargs);
if ~isbool || isrest || isoveractive
  warning('Not 1-of-n regressors');
end

if size(trainpats,1) ~= size(testpats,1)
  error('Different number of input features in training and test');
end

