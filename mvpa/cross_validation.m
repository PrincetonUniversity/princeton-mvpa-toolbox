function [subj results] = cross_validation(subj,patin,regsname,selgroup,maskgroup,class_args,varargin)

% Cross-validation classification
%
% [SUBJ RESULTS] = CROSS_VALIDATION(SUBJ,PATIN,REGSNAME,SELGROUP,MASKGROUP,CLASS_ARGS...)
%
% Calls the classifier multiple times, training and testing on
% different subsets of the data each time
%
% Adds the following objects:
% - results structure
%
% PATIN is the data that the classifier will be fed as its
% input. This can be either a single pattern or the name of a group
% of patterns.  If it is the name of a group of patterns, the size
% of this group must be consistent across patterns, selectors and
% masks. Most of the time, you'll want to feed in a single pattern
% - however, this pattern group functionality is useful for when
% your features depend on the n-minus-one themselves, e.g. when
% feeding in PCA components, where the results of the PCA will
% depend on the subset of the data used to create them.
% The same check for single object vs group is also used below for
% MASKGROUP.
%
% REGSNAME contains the targets that the classifier will be taught
% and then tested with. It will create one output unit per row. For pure
% classification, these should be binary, one condition per
% timepoint, but there is no error-checking or removal of rest
% built-in here deliberately.
%
% SELGROUP is the group of selectors that determine which are testing
% and which are training TRs for a given iteration. One selector
% per iteration. 1s = training, 2s = testing. TRs labelled with 0s
% and other values will be excluded from the classification
% Think of each set of selectors in the cell array as a kind of
% temporal mask. Each set of selectors should have the same number
% of TRs as the patterns and regressors, with 1s for the training
% TRs, 2s for the testing TRs and 0s for the TRs that you want to
% ignore. CREATE_XVALID_INDICES will create such a group.
%
% MASKGROUP is the group of masks, one per iteration, that will be
% used to decide which features are fed to the classifier. For
% instance, NOPEEKING_MULTI_ANOVA generates such a set of masks.
%
% Note: if you ran a peeking anova, you'll only have one mask, rather
% than a group. If this can't find any members of a group called
% MASKGROUP, it will treat MASKGROUP as the name of an object, and
% look instead for a single mask called MASKGROUP.
%
% PERFMET_FUNCTS(optional,default = {'perfmet_maxclass'}). The names of the
% performance metric(s) you want to use to decide how well your
% classifier did. Feed in as a cell array of strings containing
% function names that get turned into function handles later
%
% PERFMET_ARGS(optional,default = {[]}. Accompanying argument-structures, one
% for each optional perfmet_funct
%
% RAND_STATE_INT (optional, default = sum(100*clock)). If your classifier
% is non-deterministic, then you want it to initialise differently
% every time, e.g. by generating a seed based on the current time,
% which is the default. If you feed in the RAND_STATE_INT, then you can
% reproduce an analysis exactly multiple times. Either way, the state
% used is saved in results.header. Note, RAND_STATE_INT should be an
% integer, not the vector state that you get from calling
% rand('state'). Thanks to ELN for the reminder about random number
% seeds.

% See the manual for more documentation about the results
% structure.

% This is part of the Princeton MVPA toolbox, released under the
% GPL. See http://www.csbmb.princeton.edu/mvpa for more
% information.


results.header.clock = clock;

defaults.rand_state_int = sum(100*results.header.clock);
defaults.perfmet_functs = {'perfmet_maxclass'};
defaults.perfmet_args = struct([]);
args = propval(varargin,defaults);

% User-specified perfmet_args must be a cell array with a struct in
% each cell. If the user feeds in a struct, put it inside a cell array
if isstruct(args.perfmet_args)
    perfmet_args = args.perfmet_args;
    args = rmfield(args,'perfmet_args');
    args.perfmet_args{1} = perfmet_args;
    clear perfmet_args;
end

if args.rand_state_int ~= defaults.rand_state_int
  error('Rand state int argument doesn''t work properly yet');
end
rand('state',args.rand_state_int);
results.header.rand_state_int = args.rand_state_int;
results.header.rand_state_vec = rand('state');

% Load the regressors
regressors = get_mat(subj,'regressors',regsname);

% Get the names of the selectors
selnames = find_group(subj,'selector',selgroup);
nIterations = length(selnames);
if ~nIterations
  error('No selector iterations to run cross-validation over');
end

% Parse patin to use either a single pattern or a group of
% patterns. If there's only one pattern found, tile it once for each
% iteration (because we're going to use the same pattern each time)
[patnames ispatgroup] = find_group_single(subj,'pattern',patin);
if ~ispatgroup
  patnames = cellstr(repmat(patnames{1},[nIterations 1]));
end

[masknames ismaskgroup] = find_group_single(subj,'mask',maskgroup,'repmat_times',nIterations);
if ~ismaskgroup
  disp( sprintf('Using the %s mask each time',maskgroup) );
end

if length(masknames) ~= length(selnames)
  error('Your selector and mask groups have different numbers of items in them');
end

% Initialize the results structure
results.header.experiment = subj.header.experiment;
results.header.subj_id    = subj.header.id;

% Just in case the user only has one perfmet and fed it in as a
% string rather than cell array
if ~iscell(args.perfmet_functs) && ischar(args.perfmet_functs)
  % warning('Perfmet_functs should be a cell array, not a string - fixing');
  args.perfmet_functs = {args.perfmet_functs};
end

nPerfs = length(args.perfmet_functs);

sanity_check(class_args);

% Initialize subtotal_perfs - this is going to keep a running tally
% of the performance summed over iterations, separately for each
% performance metric
subtotal_perfs = zeros([nPerfs 1]);

disp( sprintf('Starting %i cross-validation classification iterations - %s', ...
	      nIterations,class_args.train_funct_name) );

for n=1:nIterations

  fprintf('\t%i',n);  
  cur_iteration = [];

  cv_args.cur_iteration = n;
  
  % Set the current selector up
  cur_selsname = selnames{n};
  selectors = get_mat(subj,'selector',cur_selsname);

  % Set up the current pattern
  cur_patname = patnames{n};
  
  % Extract the training and testing indices from the selector
  train_idx = find(selectors==1);
  test_idx  = find(selectors==2);
  rest_idx  = find(selectors==0);
  unknown_idx = selectors;
  unknown_idx([train_idx test_idx rest_idx]) = [];
  if length(unknown_idx)
    warning( sprintf('There are unknown selector labels in %s',cur_selsname) );
  end

  % Set the current mask up
  cur_maskname = masknames{n};
  masked_pats = get_masked_pattern(subj,cur_patname,cur_maskname);
  
  % Create the training patterns and targets
  trainpats  = masked_pats(:,train_idx);
  traintargs = regressors( :,train_idx);
  testpats   = masked_pats(:,test_idx);
  testtargs  = regressors( :,test_idx);

  if isempty(trainpats) && isempty(traintargs)
    disp('No pats and targs for this iteration - skipping');
    continue
  end
  
  % Create a function handle for the classifier training function
  train_funct_hand = str2func(class_args.train_funct_name);

  % Call whichever training function
  scratchpad = train_funct_hand(trainpats,traintargs,class_args,cv_args);

  % Create a function handle for the classifier testing function
  test_funct_hand = str2func(class_args.test_funct_name);
  
  % Call whichever training function
  [acts scratchpad] = test_funct_hand(testpats,testtargs,scratchpad);  
  
  % this is redundant, but it's the easiest way of
  % passing the current information to the perfmet
  scratchpad.cur_iteration = n;
  
  % Run all the perfmet functions on the classifier outputs and store
  % the resulting perfmet structure in a cell
  for p=1:nPerfs
    
    % Get the name of the perfmet function
    cur_pm_name = args.perfmet_functs{p};
    
    % Create a function handle to it
    cur_pm_fh = str2func(cur_pm_name);
    
    % Run the perfmet function and get an object back
    cur_pm = cur_pm_fh(acts,testtargs,scratchpad,args.perfmet_args{p});
    
    % Add the function's name to the object
    cur_pm.function_name = cur_pm_name;
    
    % Append this perfmet object to the array of perfmet objects,
    % only using a cell array if necessary
    if nPerfs==1
      cur_iteration.perfmet = cur_pm;
    else
      cur_iteration.perfmet{p} = cur_pm;
    end
    % Add this iteration's performance to the tally, as
    % long it's not NaN (which can happen if there were
    % no timepoints included in the xval selector for
    % that run
    cur_iteration.perf(p) = cur_pm.perf;
    if ~isnan(cur_iteration.perf(p))
      subtotal_perfs(p) = subtotal_perfs(p) + cur_iteration.perf(p);
    end
  end
  
  % Display the performance for this iteration
  disp( sprintf('\t%.2f',cur_iteration.perf(p)) );

  % Book-keep the bountiful insight from this iteration
  cur_iteration.created.datetime  = datetime(true);
  cur_iteration.train_idx         = train_idx;
  cur_iteration.test_idx          = test_idx;
  cur_iteration.rest_idx          = rest_idx;
  cur_iteration.unknown_idx       = unknown_idx;
  cur_iteration.acts              = acts;
  cur_iteration.scratchpad        = scratchpad;
  cur_iteration.header.history    = []; % should fill this in xxx
  cur_iteration.created.function  = 'cross_validation';
  cur_iteration.created.patname   = cur_patname;
  cur_iteration.created.regsname  = regsname;
  cur_iteration.created.maskname  = cur_maskname;
  cur_iteration.created.selname   = cur_selsname;
  cur_iteration.train_funct_name  = class_args.train_funct_name;
  cur_iteration.test_funct_name   = class_args.test_funct_name;
  results.iterations(n) = cur_iteration;
  
end % for n nIterations  

disp(' ');

% Show me the money
results.total_perf = subtotal_perfs / nIterations;

mainhist = sprintf( ...
    'Cross-validation using %s and %s - got total_perfs - %s', ...
    class_args.train_funct_name,class_args.test_funct_name, ...
    num2str(results.total_perf'));

results = add_results_history(results,mainhist,true);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [] = sanity_check(class_args)

if ~isstruct(class_args)
  error('Class_args should be a struct');
end

if ~isfield(class_args,'test_funct_name') || ~isfield(class_args,'train_funct_name')
  error('Need to supply training and testing function names');
end

if ~ischar(class_args.test_funct_name) || ~ischar(class_args.train_funct_name)
  error('Training or testing function names have to be strings');
end

