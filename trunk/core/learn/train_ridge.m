function [scratchpad] = train_ridge(trainpats,traintargs,in_args,cv_args)

% Use ridge regression to predict your regressors
%
% [SCRATCHPAD] = TRAIN_RIDGE(TRAINPATS,TRAINTARGS,IN_ARGS,CV_ARGS)
%
% Uses Matlab's RIDGE function. Linear regression, but
% penalises small weights (like weight regularization in
% backprop), so it's doing an implicit feature
% selection. This is an analytic solution
% (involving matrix inversion), so it's deterministic
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

defaults.penalty = NaN;
defaults.use_matlab = false;

args = mergestructs(in_args,defaults);

sanity_check(trainpats,traintargs,args);

[nVox nTimepoints] = size(trainpats);

scratchpad.class_args = args;
scratchpad.ridge.betas = NaN(nVox, 1);

% Do ridge regression on the training data:
% (linear regression but with added weight parameters)
%
% Y = traintargs'
% X = trainpats'

lambda = args.penalty;

[nConds nTimepoints] = size(traintargs);

% loop over the conditions, running ridge regression
% separately on each, and then concatenate the results
% afterwards
for c=1:nConds
  curtraintargs = traintargs(c,:);
  % we perform the regression ourselves, rather than using matlab's,
  % which does its own vaguely defined preprocessing to the data 
  if ~args.use_matlab
    scratchpad.ridge.betas(:,c) = [trainpats'; lambda*eye(nVox)]  \ ...
        [curtraintargs'; zeros(nVox,1)];
  else
    scratchpad.ridge.betas(c,:) = ridge(curtraintargs', trainpats', lambda);
  end
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
