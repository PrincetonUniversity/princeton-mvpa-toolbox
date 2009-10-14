function [acts scratch] = test_lda(testpats,testtargs,scratch)

% Testing function of LDA, normally you don't need training and testing 
% functions for LDA, but to keep cross_validation.m most flexible 
% both functions exist
%
% function [acts scratch] = test_lda(testpats,testtargs,scratch)
%
% This is the testing function that fits with TRAIN_LDA. See that
% for more info
%
% This is part of the Princeton MVPA toolbox, released under the
% GPL. See http://www.csbmb.princeton.edu/mvpa for more
% information.

% ACTS is an nOuts x nTestTimepoints matrix that contains the
% activations of the output units at test
%
% KN		ISN Hamburg  01-2007


if ~exist('scratch','var')
  scratch = [];
end

sanity_check(testpats,testtargs,scratch);

% getting the training stuff from scratch

trainpats=scratch.trainpats;
train_max_idx=scratch.train_max_idx;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% *** TRAINING THE CLASSIFIER... ***

[scratch.predictions] = classify(testpats',trainpats',train_max_idx');

acts = scratch.predictions';
acts=[acts;acts];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [] = sanity_check(testpats,testtargs,scratch)


if size(testpats,2) ~= size(testtargs,2)
  error('Different number of testing pats and targs timepoints');
end

if size(testtargs,1) ~= 2 
  error('Cannot classify more than two categories');  
end 
