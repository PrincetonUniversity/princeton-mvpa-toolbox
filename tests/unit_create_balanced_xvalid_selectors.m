function [errs warns] = unit_create_balanced_xvalid_selectors()

% [ERRS WARNS] = UNIT_CREATE_BALANCED_XVALID_SELECTORS()

errs = {};
warns = {};

% see how we create the RUNS in CREATE_TEST_SUBJ
nTimepoints = 18; 

% basic test, with all ones active selector
allones = ones(1,nTimepoints);
% DESIRED = (nIterations x nTimepoints) matrix. These are the
% probabilities that each timepoint will get picked, for a given
% cross-validation iteration, balancing separately within training and
% within testing.
desired = [1    1    1    1    1    1   ...
           1    1    1/6  1/6  1    1/3 ...
           1/6  1/6  1/6  1/6  1/3  1/3 ...
           ; ...
           1/2  1/2  1/3  1/3  1    1   ...
           1    1    1/2  1/2  1    1   ...
           1/3  1/3  1/3  1/3  1/2  1/2 ...           
           ; ...
           1    1    3/4  3/4  1    1   ...
           1    1    3/4  3/4  1    1   ...
           0    0    0    0    0    0   ...
           ];
allones_succ = run_many_balancings(allones, desired);
if ~allones_succ, errs{end+1} = 'Basic all ones test'; end

alert_unit_errors(errs,warns);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [subj] = create_test_subj(actives)

% Creates a simple test SUBJ with hardcoded RUNS and REGS.
%
% ACTIVES is a boolean vector that you want to use as the actives
% selector when creating your cross-validation selectors.


subj = init_subj('','');

runs = [1 1 1 1 1 1 ...
        2 2 2 2 2 2 ...
        3 3 3 3 3 3 ...
       ];

% row vector of indices, which we're going to convert
% into a full 1-of-n matrix
%
% - run 1 is balanced, and shouldn't need any changes
% - run 2 should whittle down to a single one of each, and throw out rest
% - run 3 should end up empty, because we're missing 2s
regs = [1 1 3 3 2 2 ...
        0 0 3 3 2 1 ...
        3 3 3 3 1 1 ...
       ];
regs = ind2vec_robust(regs);

subj = initset_object(subj,'regressors','regs',regs);
subj = initset_object(subj,'selector','runs',runs);
subj = initset_object(subj,'selector','actives',actives);

subj = create_xvalid_indices(subj,'runs', 'actives_selname','actives');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [success selprobs] = run_many_balancings(xval_actives, desired)

% This runs CREATE_BALANCED_XVALID_SELECTORS many times on the
% existing RUNS_XVAL cross-validation selectors. It then averages the
% responses to get a probability map SELPROBS of how often each
% timepoint shows up as active in the resulting, balanced selector.
%
% DESIRED is a (nXvalIterations x nTimepoints) matrix of probabilities
% showing how often we expect each timepoint to be picked on average
% (after balancing).
%
% SUCCESS is the NOT-ANY of running a t-test for each of the
% timepoints in the distribution of selectors to determine whether
% they differ significantly from the corresponding timepoint in
% SELPROBS.
%
%   There's probably a more principled way of doing this than using a
%   series of t-tests, since we're actually hoping to accept the null
%   hypothesis each time.
%
%   We don't need to correct for multiple comparisons, since we're
%   hoping to *accept* the null hypothesis, so if anything we're being
%   overly conservative here.


% the number of times to run things
% dispf('debugging mode')
nTimes = 5000;
subj = create_test_subj(xval_actives);

runs_xval = squeeze(get_group_as_matrix(subj,'selector','runs_xval'));
nXvalIterations = size(runs_xval,1);
nTimepoints = size(runs_xval,2);

assert(isequal(size(desired), [nXvalIterations nTimepoints]));

% BAL_MANY = (nXvalIterations x nTimepoints x nTimes) matrix holding
% all the balanced selectors we've created (which should be slightly
% different each time if there's any sub-sampling to balance things
% involved).
bal_many = NaN(nXvalIterations,nTimepoints,nTimes);
for n=1:nTimes
  progress(n,nTimes);
  % create a temporary version of the SUBJ structure each time
  % (CUR_SUBJ) with the most recent version of RUNS_XVAL_BAL
  cur_subj = create_balanced_xvalid_selectors(subj,'regs','runs_xval');
  runs_xval_bal = get_group_as_matrix(cur_subj,'selector','runs_xval_bal');
  runs_xval_bal = squeeze(runs_xval_bal);
  
  % we're converting to logical, because we don't actually care
  % whether it's a 1 or a 2 (i.e. training or testing, just that it's
  % included or not)
  bal_many(:,:,n) = runs_xval_bal~=0;
end % n nTimes

% SIGS = (nXvalIterations x nTimepoints) boolean matrix, with 1s for
% significant
% 
% compare each iteration of cross-validation separately
for i=1:nXvalIterations
  % now compare the distribution for each timepoint to the desired value
  for t=1:nTimepoints
    cur_des = desired(i,t);
    % (1 x NTIMES) vector of probabilities. this is the distribution
    % that we're going to compare against in the t-test
    cur_act = squeeze(bal_many(i,t,:));
    if length(unique(cur_act))==1
      % sometimes all the values are the same (e.g. all 1s), which
      % yields a NaN from TTEST, so deal with these zero-variance cases
      % specially warning('off','MATLAB:divideByZero');
      %
      % 1 if they're different, 0 if they're the same
      sig = unique(cur_act)~=cur_des;
    else
      % if H == 1, it's significant at p<0.05. if H == 0, it's not
      % significant, e.g. ttest(randn(10,1)+5, 5) == 0
      sig = ttest(cur_act, cur_des);
    end % sig
    sigs(i,t) = sig;
  end % t nTimepoints
end % i nIterations

success = ~any(sigs(:));

bal_mean = mean(bal_many,3);

% let's also do a simpler test as a failsafe. require all the values
% in BAL_MEAN to be within 0.1 of DESIRED
if any(abs(bal_mean(:)-desired(:))>.1), success = false; end

%save

if ~success
  dispf('Bleurgh. Failure')
  keyboard
end


