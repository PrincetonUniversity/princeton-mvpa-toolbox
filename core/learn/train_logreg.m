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
% PENALTY (required, default = NaN). You have to specify a PENALTY, or
% this function will fail fatally. I usually set this to around 50 for
% 1000 voxels. The more voxels you have, the higher the penalty.
%
% MAXROUNDS (optional, default = 5000) The maximum number of
% iterations used by the iteratively-reweighted least squares
% (IRLS) algorithm. Typically no more than 8 are required.
%
% TOL (optional, default = 1e-4) The stopping criterion of the IRLS
% algorithm: when the decrease in loglikelihood is below this
% proportion, the algorithm returns.
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
defaults.maxrounds = 5000;
defaults.penalty = NaN;
defaults.use_matlab = false;
defaults.constant = false;
defaults.scale_penalty = false;

args = mergestructs(in_args,defaults);

sanity_check(trainpats,traintargs,args);

if args.scale_penalty
  args.penalty = rows(trainpats) * args.penalty;
end

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
  out = logRegFun(curtraintargs, trainpats, lambda, args.tol, args.maxrounds);
  scratchpad.logreg.betas(:,c) = out.weights';
  scratchpad.logreg.trainError(c,:) = out.classError;
  scratchpad.logreg.rounds(c) = out.rounds;
  scratchpad.logreg.ll{c} = out.ll;  
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [] = sanity_check(trainpats,traintargs,args)

if any(isnan(args.penalty))
  error('You have to specify a ridge penalty');
end

% % this isn't an issue now, because it just loops over the rows
% if size(traintargs, 1) ~= 1
%   error('Targets must be a row vector, not %s', mat2str(size(traintargs))); 
% end

if any(isnan(trainpats))
  error('trainpats cannot be NaN');
end
if any(isnan(traintargs))
  error('traintargs cannot be NaN');
end

