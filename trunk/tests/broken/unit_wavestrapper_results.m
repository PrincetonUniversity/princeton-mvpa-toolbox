function [errs warns] = unit_wavestrapper_results()

% [ERRS WARNS] = UNIT_WAVESTRAPPER_RESULTS()


errs = {};
warns = {};

errs = very_significant_sine(errs);
errs = not_significant_rand(errs);
errs = varying_significant_sine(errs);

% alert the user if there are any problems
[errs warns] = alert_unit_errors(errs,warns);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [errs] = very_significant_sine(errs)

nConds = 3;
nTimepoints = 240;
nIterations = 6;

regs = fake_smooth_regs(nConds, nTimepoints, 0.2);

% these are designed to be pretty awesome fake classifier
% outputs
do_plot = false;
acts = noisify_regressors(regs, 1, 0.9, 'uniform', 'ascending', do_plot);

for c=1:nConds
  % normalize each ACTS row to have a max of 1
  acts(c,:) = acts(c,:) / max(acts(c,:));
end

results = create_fake_results(acts, regs, nIterations);

[pval actual_val null_vals] = wavestrapper_results(results,'nshuffles',200);

% chose 0.001 as a threshold for failing the test
% arbitrarily
if pval>0.001
  errs{end+1} = 'Pval should be significant';
end

  
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [errs] = not_significant_rand(errs)

% generate smoothish REGS, and completely random unrelated
% ACTS

nConds = 3;
nTimepoints = 240;
nIterations = 6;
noisiness = 0.2;

regs = fake_smooth_regs(nConds, nTimepoints, noisiness);

% these are designed to be pretty awesome fake classifier
% outputs
do_plot = false;
acts = rand(size(regs));

for c=1:nConds
  % normalize each ACTS row to have a max of 1
  acts(c,:) = acts(c,:) / max(acts(c,:));
end

results = create_fake_results(acts, regs, nIterations);

[pval actual_val null_vals] = wavestrapper_results(results,'nshuffles',200);

% chose 0.1 as a threshold for failing the test arbitrarily
if pval<0.1
  errs{end+1} = 'Pval should not be significant';
end
  



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [errs] = varying_significant_sine(errs)

% generate smoothish REGS, and then add varying amounts of
% noise to them to create the ACTS


nConds = 3;
nTimepoints = 240;
nIterations = 6;
noisiness = 0.2;

regs = fake_smooth_regs(nConds, nTimepoints, noisiness);

do_plot = false;
% add varying amounts of noise to REGS to create
% ACTS. ACTS_1 should be pretty significant, ACTS_50
% should be pretty insignificant
acts_1   = noisify_regressors(regs, 1, 1,   'uniform', 'ascending', do_plot);
acts_10  = noisify_regressors(regs, 1, 10,  'uniform', 'ascending', do_plot);
acts_100 = noisify_regressors(regs, 1, 100, 'uniform', 'ascending', do_plot);

for c=1:nConds
  % normalize each ACTS row to have a max of 1
  acts_1(c,:)  = acts_1(c,:)  / max(acts_1(c,:));
  acts_10(c,:)  = acts_10(c,:)  / max(acts_10(c,:));
  acts_100(c,:) = acts_100(c,:) / max(acts_100(c,:));
end

results_1   = create_fake_results(acts_1,   regs, nIterations);
results_10  = create_fake_results(acts_10,  regs, nIterations);
results_100 = create_fake_results(acts_100, regs, nIterations);

[pval_1   actual_val_1   null_vals_1]   = wavestrapper_results(results_1,'nshuffles',200);
[pval_10  actual_val_10  null_vals_10]  = wavestrapper_results(results_10,'nshuffles',200);
[pval_100 actual_val_100 null_vals_100] = wavestrapper_results(results_100,'nshuffles',200);

if (pval_1 < pval_10) & (pval_10 < pval_100)
  % all is well
else
  errs{end+1} = 'The order of the pvals is wrong'
end
  


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [results] = create_fake_results(acts, regs, nIterations)

% Creates a fake, barebones RESULTS structure (enough to
% feed in to WAVESTRAPPER_RESULTS.M) from the ACTS and
% REGS. Splits them up first into nIterations.

[nConds nTimepoints] = size(acts);

if mod(nTimepoints, nIterations)
  error('nTimepoints must be divisible by nIterations')
end

% we want to divide the ACTS and REGS up into separate
% iterations
%
% START_IDX, e.g. for 24 timepoints with 6 iterations, =
% [1 5 9 13 17 21];
start_idx = nTimepoints/nIterations * [0:nIterations-1] + 1;
% END_IDX, e.g. for 24 timepoints with 6 iterations, = [4 8
% 12 16 20 24]
end_idx = nTimepoints/nIterations * [1:nIterations];

for n=1:nIterations
  cur_start = start_idx(n);
  cur_end = end_idx(n);
  results.iterations(n).acts = acts(:, cur_start:cur_end);
  results.iterations(n).perfmet.desireds = regs(:, cur_start:cur_end);
  
end % n nIterations

