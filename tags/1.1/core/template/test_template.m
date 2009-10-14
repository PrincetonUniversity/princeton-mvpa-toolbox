function [acts scratchpad] = test_template(testpats,testtargs,scratchpad)

% Template testing function
%
% [ACTS SCRATCHPAD] = TEST_TEMPLATE(TESTPATS,TESTTARGS,SCRATCHPAD)
%
% This is the template testing function to use when creating your
% own classifier testing function. Gets called after TRAIN_TEMPLATE
%
% See also: test_bp.m and train_template.m
%
% ACTS is an nOuts x nTestTimepoints matrix that contains the
% activations of the output units at test

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


sanity_check(testpats,testtargs,scratchpad);


%%% test generalization performance on the test data

%%% save the activations into ACTS (nOuts x nTestTimepoints)
acts = zeros(size(testtargs));

%%% add to the scratchpad if there's anything new to say



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [] = sanity_check(testpats,testtargs,scratchpad)

% check that your assumptions are met here
