function [new_results all_acts all_test_idx] = apply_trained_classifier(subj,old_results,regsname,sel_test_name,varargin)

% [NEW_RESULTS ALL_ACTS ALL_TEST_IDX] = APPLY_TRAINED_CLASSIFIER(SUBJ,OLD_RESULTS,REGSNAME,SEL_TEST_NAME, ...)
%
% Takes the OLD_RESULTS structure (including its already-trained
% classifiers), and reapplies them on a different set of
% timepoints.
%
% Currently, it makes the reasonable assumption that it only
% makes sense to test a classifier on the same pattern and
% mask that it was trained on, so doesn't take those in as
% arguments. It does allow you to change the regressors
% (REGSNAME) and the selectors you use (SEL_TEST_NAME),
% though it only uses the 2s.
%
% Does not yet implement all of the optional args that
% CROSS_VALIDATION.M allows.
%
% PERFMET_NAME (optional, default = 'perfmet_maxclass'). Unlike
% CROSS_VALIDATION.M, this currently only allows you to choose a
% single PERFMET. Otherwise, works the same.
%
% IGNORE_PEEKING (optional, default = false). By default, will screech
% if you try and test on any of the timepoints you trained on.
%
% PERFMET_ARGS (optional, default = struct([])). Arguments for
% the PERFMET_NAME, as per CROSS_VALIDATION.M.

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


% PERFMET function name
defaults.perfmet_name = 'perfmet_maxclass';
defaults.perfmet_args = struct([]);
defaults.pm_name = false; % deprecated
defaults.pm_args = false; % deprecated
defaults.ignore_peeking = false;

args = propval(varargin,defaults);

if args.pm_name | args.pm_args
  error('PM_NAME and PM_ARGS have been renamed to PERFMET_NAME and PERFMET_ARGS');
end

% get the selector group that was used to train the
% classifiers in OLD_RESULTS from the group name of the
% first iteration's selector
sel_train_name = get_objfield(subj, ...
                              'selector', ...
                              old_results.iterations(1).created.selname, ...
                              'group_name');

% we've already used one selector for cross-validation training
% our classifier, then we're going to apply this classifier
% (outside of CROSS_VALIDATION.M) to the corresponding
% iteration of the testing selector
%
% first, check that we have the right number of iterations
% and that the second selector group isn't peeking
nTestTimepoints = sanity_check_sels(subj,sel_train_name, sel_test_name, args);


%%%%%
% for each iteration, take the trained classifier and test
% it on the SEL_TEST_NAME timepoints, stringing all the ACTS
% together into one ALL_ACTS

nIterations = length(old_results.iterations);
all_acts = [];
all_test_idx = [];

% we won't use this, but we will store it in each
% OLD_RESULTS iteration's CREATED field
sel_train_names = find_group_single(subj,'selector',sel_train_name);

sel_test_names = find_group_single(subj,'selector',sel_test_name);
if length(sel_test_names) ~= nIterations
  error('Wrong number of SEL_TEST_NAME members');
end

class_args = old_results.iterations(1).scratchpad.class_args;
test_funct_hand = str2func(class_args.test_funct_name);

regs = get_mat(subj,'regressors',regsname);

for n=1:nIterations

  fprintf('\t%i',n);  
  cur_it = [];
 
  cur_sel_test_name = sel_test_names{n};
  cur_sel = get_mat(subj,'selector',cur_sel_test_name);

  cur_patname = old_results.iterations(1).created.patname;
  cur_maskname = old_results.iterations(n).created.maskname;
  masked_pats = get_masked_pattern(subj,cur_patname,cur_maskname);
  
  test_idx = find(cur_sel==2);
  
  testpats  = masked_pats(:,test_idx);
  testtargs = regs(:,test_idx);

  scratchpad = old_results.iterations(n).scratchpad;
  
  [acts scratchpad] = test_funct_hand(testpats,testtargs,scratchpad);

  scratchpad.cur_it = n;
  
  perfmet_fh = str2func(args.perfmet_name);
    
  % Run the perfmet function and get an object back
  pm = perfmet_fh(acts, testtargs, scratchpad, args.perfmet_args);
  pm.function_name = args.perfmet_name;
  cur_it.perfmet = pm;

  % UPDATED to allow storage of NaNs
  %
  % Even though we're not not allowing multiple PERFMETs,
  % we're going to store them in the same way as
  % CROSS_VALIDATION.M.
  cur_it.perf(1) = pm.perf;
  % nPerfs x nIterations
  store_perfs(1,n) = cur_it.perf(1);
  
  % Display the performance for this iteration
  disp( sprintf('\t%.2f',cur_it.perf(1)) );

  % Book-keep the bountiful insight from this iteration
  cur_it.created.datetime  = datetime(true);
  cur_it.test_idx          = test_idx;
  cur_it.acts              = acts;
  cur_it.scratchpad        = scratchpad;
  cur_it.created.function  = 'cross_validation';
  cur_it.created.patname   = cur_patname;
  cur_it.created.regsname  = regsname;
  cur_it.created.maskname  = cur_maskname;
  cur_it.created.sel_test_name   = cur_sel_test_name;
  cur_it.created.orig_train_selname = sel_train_names{n};
  cur_it.args              = args;
  new_results.iterations(n) = cur_it;
  
  all_acts = [all_acts acts];
  all_test_idx = [all_test_idx test_idx];
  
end % i nIterations

disp(' ');

% Show me the money
new_results.total_perf = nanmean(store_perfs,2);

mainhist = sprintf( ...
    'Reapplying trained classifier using %s timepoints instead of %s - got total_perfs - %s', ...
    sel_test_name, sel_train_name, ...
    num2str(new_results.total_perf'));

new_results = add_results_history(new_results,mainhist,true);
new_results.header.subj_id = old_results.header.subj_id;
new_results.header.experiment = old_results.header.experiment;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [nTestTimepoints] = sanity_check_sels(subj,sel_train_name, sel_test_name, args)

% it's important that none of the SEL_TRAIN_NAME 1s show up as
% SEL_TEST_NAME 2s (because that would be peeking), so check this
% now
all_sel_train = get_group_as_matrix(subj,'selector',sel_train_name);
all_sel_test = get_group_as_matrix(subj,'selector',sel_test_name);

% check that there are the same number of members in both
% groups
%
% it doesn't matter if they have different numbers of
% timepoints
if size(all_sel_train,1) ~= size(all_sel_test,1)
  error('Different number of selectors in train and test groups');
end

if count(all_sel_train==1 & all_sel_test==2 & ~args.ignore_peeking)
  error('Peeking issue');
end

% while we're here, check how many test timepoints there are
% going to be
nTestTimepoints = count(all_sel_test==2);
