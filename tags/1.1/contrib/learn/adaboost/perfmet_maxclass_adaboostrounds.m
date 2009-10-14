function [perfmet] = perfmet_maxclass_adaboostrounds(acts,targs,scratchpad,args)
%
% [PERFMET] = PERFMET_MAXCLASS_ADABOOSTROUNDS(ACTS,TARGS,SCRATCHPAD,ARGS)
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
% Author: Melissa K. Carroll
%
% Produces the same results as perfmet_maxclass.m, except that
% minimum exponential loss is evaluated, rather than maximum activation,
% and desireds, corrects, and pcntcorrect are output for every training round
% of AdaBoost, allowing one to evaluate the change in test
% performance over AdaBoost rounds.
%
% NOTE: rest conditions (sum(traintargs,1) == 0) are exluded from
% evaluation.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% remove rest conditions
nonrest = find(sum(targs,1) > 0);
targs = targs(:,nonrest);

% calculate dataset dimensions
numex = size(targs,2);
numclass = size(targs,1);
numrounds = size(scratchpad.actsarchive,3);

% compute the class and exponential loss (conf) of the predicted class for
% each example for each AdaBoost round using the exponential losses stored
% in actsarchive, where the class with minimal loss is the prediction
[conf pred] = min(scratchpad.actsarchive,[],1);
% determine the target (correct) output (targ) for each class for each example by
% taking the maximum of targs for each example; val is discarded
[val targ] = max(targs,[],1);
% targ is of size 1 * numexamples
% make the matrix dimensions consistent; pred will be numexamples *
% numrounds
pred = squeeze(pred);
% create a "correct" score for each example for each round by comparing the
% transpose of targ to pred
% correct is of size numexamples * numrounds
correct = (pred == repmat(targ',1,numrounds));
% calculat the percent correct for each round by summing over all example
% and dividing by the number of examples
pcntcorrect = sum(correct,1)/size(correct,1);     

% save the computed matrices in their appropriate fields
% see perfmet_template.m for more details on these output arguments
% note again that, unlike the MVPA default, these statistics are computed for
% each round of AdaBoost performed
perfmet.guesses    = pred;
perfmet.desireds   = targ;
perfmet.corrects   = correct;
perfmet.pcntcorrect = pcntcorrect;
perfmet.perf       = pcntcorrect(1,numrounds);
perfmet.scratchpad = [];