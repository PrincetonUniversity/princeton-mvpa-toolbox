function [acts scratchpad] = test_bp(testpats,testtargs,scratchpad)

% Testing function for BP
%
% [ACTS SCRATCHPAD] = TEST_BP(TESTPATS,TESTTARGS,SCRATCHPAD)
%
% This is the testing function that fits with TRAIN_BP. See that
% for more info
%
% ACTS is an nOuts x nTestTimepoints matrix that contains the
% activations of the output units at test


sanity_check(testpats,testtargs,scratchpad);

% Now test generalization performance on the test data
scratchpad.testing_acts_posttraining = sim(scratchpad.net,testpats);

% Finally, spit out the acts
acts = scratchpad.testing_acts_posttraining(scratchpad.outidx,:);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [] = sanity_check(testpats,testtargs,scratchpad)

nOuts = length(scratchpad.outidx);

if nOuts ~= size(testtargs,1)
  error('Problem with number of feature units');
end

if size(testpats,2) ~= size(testtargs,2)
  error('Different number of testing pats and targs timepoints');
end


