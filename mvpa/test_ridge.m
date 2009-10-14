function [acts scratchpad] = test_ridge(testpats,testtargs,scratchpad)

% Generates predictions using a trained ridge regression model
%
% [ACTS SCRATCHPAD] = TEST_RIDGE(TESTPATS,TESTTARGS,SCRATCHPAD)
%
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

% output predictions goes into "ACTS"
acts = zeros(size(testtargs));

% get w vector
w = scratchpad.ridge.betas;

% prediction is same as linear regression
acts = (w' * testpats);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [] = sanity_check(testpats,testtargs,scratchpad)

% check that your assumptions are met here
if ~isfield(scratchpad, 'ridge')
  error('Unable to find output from train_ridge in scratchpad');
end

if size(testtargs, 1) ~= 1
  error('Targets must be row vector');
end

if isnan(testpats)
  error('testpats cannot be NaN');
end

