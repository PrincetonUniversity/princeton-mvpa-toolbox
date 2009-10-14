function [scratch] = train_gnb(trainpats,traintargs, in_args, cv_args)

% Use a Gaussian Naive Bayes classifier to learn regressors.
%
% [SCRATCH] = TRAIN_GNB(TRAINPATS, TRAINTARGS, IN_ARGS, CV_ARGS)
%
% The Gaussian Naive Bayes classifier makes the assumption that
% each data point is conditionally independent of the others, given
% a class label, and that, furthermore, the likelihood function for
% each class is normal.  The likelihood of a given data point X,
% where Y is one of K labels, is thus:
%
% Pr ( X | Y==K) = Product_N ( Normal(X_N | theta_K) ) 
% 
% The GNB is trained by finding the Normal MLE's for each subset of
% the training set that have the same label.  Each voxel has a
% scalar mean and a scalar variance.
%
% OPTIONAL ARGUMENTS:
%
% UNIFORM_PRIOR (default = true): If uniform_prior is true,
% then the algorithm will assume that no classes are
% inherently more likely than others, and will use 1/K as
% the prior probability for each of K classes.  If
% uniform_prior is false, then train_gnb will estimate the
% priors from the data using laplace smoothing: if N_k is
% the number of times class k is observed in the training
% set and N is the total number of training datapoints, then
% Pr(Y == k) = (N_k + 1) / (N + K).  This way, no cluster is
% ever assigned a 0 prior.

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

defaults.uniform_prior = true;

args = mergestructs(in_args, defaults);

nConds = size(traintargs,1);
[nVox nTimepoints] = size(trainpats);

% find a gaussian distribution for each voxel for each category

scratch.mu = NaN(nVox, nConds);
scratch.sigma = NaN(nVox, nConds);

for k = 1:nConds

  % grab the subset of the data with a label of category k
    k_idx = find(traintargs(k, :) == 1);

    if numel(k_idx) < 1
      error('Condition %g has no data points.', k);
    end
    
    data = trainpats(:, k_idx);

    % calculate the maximum likelihood estimators (mean and variance)
    [ mu_hat, sigma_hat] = normfit(data');

    scratch.mu(:,k) = mu_hat;
    scratch.sigma(:,k) = sigma_hat;
    
end

%calculate the priors based on occurence in the training set
scratch.prior = NaN(nConds, 1);
if (args.uniform_prior)
  scratch.prior = ones(nConds,1) / nConds;
else
  
  for k = 1:nConds  
    scratch.prior(k) = (1 + numel( find(traintargs(k, :) == 1))) / ...
        (nConds + nTimepoints);    
  end
  
end

