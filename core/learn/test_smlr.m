function [acts scratchpad] = test_smlr(testpats,testtargs,scratchpad)

% Generates predictions using a trained multinomial regression model.
%
% [ACTS SCRATCHPAD] = TEST_SMLR(TESTPATS,TESTTARGS,SCRATCHPAD)
%
% SEE ALSO SMLR, TRAIN_SMLR

% License:
% ======================================================================
%
% This is part of the Princeton MVPA toolbox, released under the
% GPL. See http://www.csbmb.princeton.edu/mvpa for more
% information.
% 
% The Princeton MVPA toolbox is available free and
% unsupported to those who might find it useful. We do not
% take any responsibility whatsoever for any problems that
% you have related to the use of the MVPA toolbox.
%
% ======================================================================

sanity_check(testpats,testtargs,scratchpad);

w = scratchpad.w;

% Check if we need to add a fixed set of weights
if ~scratchpad.class_args.fit_all
  w(end,end+1) = 0; % add additional column of zeros
end

% Check if we need to add a fixed constant to the input
if scratchpad.class_args.constant
  testpats = [ones(1,cols(testpats)); testpats];
end

scratchpad.test_w = w;

% Use logistic multinomial probability to make predictions
acts = exp(testpats' * w)./ repmat(sum(exp(testpats' * w),2),[1 size(w,2)]);
acts = acts';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [] = sanity_check(testpats,testtargs,scratchpad)

if length(find(isnan(testpats)))
  error('testpats cannot be NaN');
end

