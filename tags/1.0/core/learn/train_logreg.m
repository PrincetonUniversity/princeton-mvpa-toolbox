function [scratchpad] = train_logreg(trainpats,traintargs,in_args,cv_args)

% Uses logistic regression with regularization to predict your regressors
%
% [SCRATCHPAD] = TRAIN_RIDGE(TRAINPATS,TRAINTARGS,IN_ARGS,CV_ARGS)
%
% Logistic regression, but penalises small weights (like weight
% regularization in backprop), so it's doing an implicit feature
% selection.
%
% The only parameter is the penalty parameter (how much to
% penalize low weights), which scales with the number of
% features you have, so it could easily get high (e.g. 10^4
% for lots of features) - see PENALTY
%
% PENALTY (optional, default = NaN). You have to specify
% a PENALTY, or this function will fail fatally.
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

defaults.tol = 1e-4;
defaults.penalty = NaN;
defaults.use_matlab = false;
defaults.constant = false;

args = mergestructs(in_args,defaults);

sanity_check(trainpats,traintargs,args);

[nVox nTimepoints] = size(trainpats);

scratchpad.class_args = args;
scratchpad.constant = args.constant;

if args.constant
  trainpats = [ones(1,cols(trainpats)); trainpats];
  scratchpad.logreg.betas = NaN(nVox+1, 1);
else
  scratchpad.logreg.betas = NaN(nVox, 1);  
end

% Do logreg regression on the training data:
% (logistic regression but with added weight parameters)
%
% Y = traintargs'
% X = trainpats'

lambda = args.penalty;

[nConds nTimepoints] = size(traintargs);

% loop over the conditions, running logistic regression
% separately on each, and then concatenate the results
% afterwards
for c=1:nConds
  curtraintargs = traintargs(c,:);
  out = logRegFun(curtraintargs, trainpats, lambda, args.tol);
  scratchpad.logreg.betas(:,c) = out.weights';
  scratchpad.logreg.trainError(c,:) = out.classError;
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [] = sanity_check(trainpats,traintargs,args)

if isnan(args.penalty)
  error('You have to specify a ridge penalty');
end

% % this isn't an issue now, because it just loops over the rows
% if size(traintargs, 1) ~= 1
%   error('Targets must be a row vector, not %s', mat2str(size(traintargs))); 
% end

if isnan(trainpats)
  error('trainpats cannot be NaN');
end
if isnan(traintargs)
  error('traintargs cannot be NaN');
end
