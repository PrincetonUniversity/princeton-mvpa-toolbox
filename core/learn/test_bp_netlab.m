function [acts scratch] = test_bp_netlab(testpats,testtargs,scratch)

% Testing function for BP_Netlab
%
% [ACTS SCRATCHPAD] = TEST_BP_NETLAB(TESTPATS,TESTTARGS,SCRATCHPAD)
%
% This is the template testing function that fits with
% TRAIN_BP_NETLAB. See that for more info
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

testpats = testpats';
testtargs = testtargs';

%%% save the activations into ACTS (nOuts x nTestTimepoints)
%testing the network using the testpats
% acts = nTRs x nConds
[mlp_outputs] = mlpfwd(scratch.net,testpats);
acts = mlp_outputs';


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [] = sanity_check(testpats,testtargs,scratchpad)

if size(testpats,2) ~= size(testtargs,2)
  error('Different number of testing pats and targs timepoints');
end


