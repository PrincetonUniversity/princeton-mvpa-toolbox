function [acts scratchpad] = test_logreg(testpats,testtargs,scratchpad)

% Generates predictions using a trained logistic regression model
%
% [ACTS SCRATCHPAD] = TEST_RIDGE(TESTPATS,TESTTARGS,SCRATCHPAD)
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

sanity_check(testpats,testtargs,scratchpad);

if scratchpad.constant
  testpats = [ones(1,cols(testpats)); testpats];
end

% output predictions goes into "ACTS"
acts = zeros(size(testtargs));

%[nConds nTimepoints] = size(testtargs);
nConds = cols(scratchpad.logreg.betas);

for c = 1:nConds
  % get weights vector
  w = scratchpad.logreg.betas(:,c);
  
  % prediction is same as linear regression
  % taken from logRegFun.m
  p=[];
  acts(c,:)=exp(w'*testpats)./(1+exp(w'*testpats));

end

scratchpad.w = scratchpad.logreg.betas;
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [] = sanity_check(testpats,testtargs,scratchpad)

% check that your assumptions are met here
if ~isfield(scratchpad, 'logreg')
  error('Unable to find output from train_logreg in scratchpad');
end

% if size(testtargs, 1) ~= 1
%   error('Targets must be row vector');
% end

if length(find(isnan(testpats)))
  error('testpats cannot be NaN');
end

