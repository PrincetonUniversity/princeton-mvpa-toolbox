function [acts,scratch] = test_gnb(testpats,testtargs, scratch)

% Use a Gaussian Naive Bayes classifier to predict regressors.
% 
% [ACTS, SCRATCHPAD] = TEST_GNB(TESTPATS, TESTTARGS, SCRATCH)
%
% See TRAIN_GNB for more info.

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

nConds = size(testtargs,1);

[nVox nTimepoints] = size(testpats);

% To make a prediction for a given test pattern, we compute the
% posterior likelihood of observing the label for the given
% pattern:
%
% Pr(Y = y | X = x) ~ Pr( X = x | Y = y) * Pr (Y = y)

warning('off');
% compute the likelihood of the data under the MLE estimated
% gaussian model for each category
for k = 1:nConds

  % we calculate the proper mu and sigma for each voxel and each
  % timepoint:
  
  % scratch.mu is a nVox x 1 vector of voxel means for that condition
  mu = repmat(scratch.mu(:,k), 1, nTimepoints);

  % scratch.sigma is a nVox x 1 vector of voxel variances for a condition 
  sigma = repmat(scratch.sigma(:,k), 1, nTimepoints);

  % compute the likelihood of the data under label k (this just the
  % value of the gaussian equation using the estimated means and variances)
  raw_likelihood = normpdf(testpats, mu, sigma);
  
  % GNB assumes all voxels are independent, so we multiply these probabilities
  % together to get the likelihood of each data point: we do this in
  % the log domain by summing to avoid underflow
  log_likelihood(k, :) = sum(log(raw_likelihood), 1);
end

% with uniform priors, the final log posterior is just the
% normalized log likelihood.  We would normally try to normalize
% within logs to avoid underflow, but that doesn't seem to be
% necessary here.

% (we don't technically need to change variable names here, but it
% makes it more correct if we want to add a prior)
log_posterior = log_likelihood + repmat(log(scratch.prior), 1, nTimepoints);

% normalize the likelihoods in the real domain
acts = exp(log_posterior);
acts = acts ./ repmat(sum(acts,1), nConds, 1);


