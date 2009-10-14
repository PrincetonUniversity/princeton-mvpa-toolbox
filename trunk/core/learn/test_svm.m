function [acts scratch] = test_svm(testpats,testtargs,scratch)

% Testing function for SVM
%
% [ACTS SCRATCH] = TEST_SVM(TESTPATS,TESTTARGS,SCRATCH)
%
% This is the testing function that fits with TRAIN_SVM. See that
% for more info
%
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

% ACTS is an nOuts x nTestTimepoints matrix that contains the
% activations of the output units at test


if ~exist('scratch','var')
  scratch = [];
end

[test_max_val test_max_idx]  = max(testtargs);

sanity_check(testpats,testtargs,scratch);
test_max_idx(test_max_idx == 1) = 1;
test_max_idx(test_max_idx == 2) = -1;


% Now test generalization performance on the test data
[scratch.err, scratch.predictions] = svmclassify(testpats',test_max_idx',scratch.model);

acts = '';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [] = sanity_check(testpats,testtargs,scratch)


if size(testpats,2) ~= size(testtargs,2)
  error('Different number of testing pats and targs timepoints');
end

if size(testtargs,1) ~= 2 
  error('Cannot classify more than two categories');  
end 
