function [actives_bal] = balance_active_selector(conds,actives)

% [ACTIVES_BAL] = BALANCE_ACTIVE_SELECTOR(CONDS,ACTIVES)
%
% Takes in a single boolean actives selector ACTIVES, as well as the
% conditions regressor CONDS, and returns a whittled actives selector
% ACTIVES_BAL that balances the number of timepoints in each
% condition. UPDATE: if the active selector ACTIVES has 1s during rest,
% those 1s will be kept.
%
% Rather than calling this directly, you probably want to call it from
% CREATE_BALANCED_XVALID_SELECTORS to make this work for both training
% and testing in cross-validation iterations. Gets tested in
% UNIT_CREATE_BALANCED_XVALID_SELECTORS.


[nConds nTimepoints] = size(conds);

[isbool isrest isover] = check_1ofn_regressors(conds);
assert(isbool);
assert(~isover)

% COND_INCL_BOOL = (nConds x nTimepoints) boolean of timepoints that
% are in selector ACTIVES *and* from this row's condition
cond_incl_bool = [];
for c=1:nConds
  cond_incl_bool(c,:) = actives & conds(c,:);
end % c nConds

% find the timepoints that are active in the selector ACTIVES, but
% inactive (i.e. rest) in the CONDS
actives_rest = actives & ~sum(conds,1);

% what's the minimum number of timepoints in any of the conditions?
min_counts = min(sum(cond_incl_bool,2));

for c=1:nConds
  % indices of active timepoints for this condition
  cur_cond_idx = find(cond_incl_bool(c,:));
  % how many surplus timepoints in this condition
  cur_surplus = length(cur_cond_idx) - min_counts;
  % SAMPLE can't return 0 samples, so skip to the next condition if
  % there are no surplus timepoints
  if ~cur_surplus, continue, end
  % pick a random subset to remove, bringing the number of active
  % timepoints for this condition down to MIN_COUNTS
  remove_idx = sample(cur_cond_idx,cur_surplus);
  cond_incl_bool(c,remove_idx) = 0;
end % c nConds

for c=1:nConds
  % now, all the conditions should have the same number of timepoints
  assert(count(cond_incl_bool(c,:))==min_counts);
end % c nConds

% re-confirm that none of the timepoints are overactive
[isbool isrest isover] = check_1ofn_regressors(cond_incl_bool);
assert(~isover)

% now, we can just OR together the three sets of booleans to get an
% actives selector that has equal numbers of timepoints in each
% condition. we'll also add back in any rest timepoints that had a 1
% in the actives ACTIVES.
actives_bal = sum(cond_incl_bool,1) + actives_rest;
assert(count(actives_bal)==min_counts*nConds + count(actives_rest));


