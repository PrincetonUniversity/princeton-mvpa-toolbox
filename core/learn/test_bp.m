function [acts scratch] = test_bp(testpats,testtargs,scratch)

% Testing function for BP
%
% [ACTS SCRATCH] = TEST_BP(TESTPATS,TESTTARGS,SCRATCH)
%
% This is the testing function that fits with TRAIN_BP. See that
% for more info
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


if ~exist('scratch','var')
  scratch = [];
end

sanity_check(testpats,testtargs,scratch);

% Now test generalization performance on the test data
scratch.testing_acts_posttraining = sim(scratch.net,testpats);

% Finally, spit out the acts
acts = scratch.testing_acts_posttraining(scratch.outidx,:);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [] = sanity_check(testpats,testtargs,scratch)

nOuts = length(scratch.outidx);

if nOuts ~= size(testtargs,1)
  error('Problem with number of feature units');
end

if size(testpats,2) ~= size(testtargs,2)
  error('Different number of testing pats and targs timepoints');
end


