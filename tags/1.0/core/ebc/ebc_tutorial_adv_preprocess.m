function [subj] = ebc_tutorial_adv_preprocess(subj, default_params, varargin)

% Runs the pre-processing phase of the advanced EBC tutorial.
%
% [SUBJ] = EBC_TUTORIAL_ADV_PREPROCESS(SUBJ, DEFAULT_PARAMS, ...)
%
% Performs z-scoring, moving of the original pattern to HD, then
% creates cross validation selectors, all regressors objects, and
% performs a non-peeking cross correlation feature selection to
% create masks for each iteration.  DEFAULT_PARAMS is needed for
% the number of voxels to be included in the mask.
%
% Optional Arguments:
%
% NOBLANKS (default = true): if true, then blanks will be excluded
% from the cross validation selectors.
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

% Get default optional arguments
defaults.noblanks = true;

% PROPVAL is the standard MVPA method for dealing with optional
% arguments: we pass in the VARARGIN special input variable that
% contains the extra argument pairs the user supplied, and we also
% supply a DEFAULTS structure that contains the default values of
% these extra arguments.  The string names of the property-value
% pairs are mapped to fields in the resulting structure, and errors
% and warnings are given if invalid arguments are supplied by the
% user.
%
% In this case, if we were to add the property-value pair
% {'noblanks', false} as extra arguments, that would
% override the default value of 'true', and args.noblanks
% would be 'false'.
args = propval(varargin, defaults);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Step 3 - Pre-processing.
%
% Once again, we detrend and zscore the data, conserve ram by moving
% the patterns to the hard drive, and separate regressors.  These
% commands are mostly identical to the first tutorial.
fprintf('Starting pre-processing on subject ''%s''...\n', subj.header.id);

% detrend the data
subj = apply_to_runs(subj, 'epi', 'movies', 'apply_detrend', ...
                     'new_patname', 'epi_dt');

% conserve RAM and remove the old pattern
subj = remove_object(subj, 'pattern', 'epi');
%subj = move_pattern_to_hd(subj, 'epi');

% zscore the detrended data
subj = apply_to_runs(subj, 'epi_dt', 'movies', 'apply_zscore', ...
                     'new_patname', 'epi_z');

% conserve RAM again
subj = remove_object(subj, 'pattern', 'epi_dt');
%subj = move_pattern_to_hd(subj, 'epi_dt');

% create our regressors
subj = separate_regressors(subj, 'baseregs');

% create our cross validation selectors.
if args.noblanks % if we are to remove blanks
  
  subj = create_xvalid_indices(subj, 'movies', ...
                               'actives_selname', 'movies_noblank'); 
  
else % if we are not to remove blanks

  % unlike in the introduction tutorial, we allow for the option of
  % leaving blanks in during the training set.  Because this is an
  % unorthodox practice MVPA assumes that rest should be included
  % in training and testing or in neither; however, our performance
  % metric will give artifically inflated scores if we include
  % blank trials in the test set, and blanks are removed in the
  % final EBC Feature_Rater scoring program.  
  %
  % Because of this, we need to manually remove the blank TRs from our test
  % set, even when we include them in our training set.
  subj = create_xvalid_indices(subj, 'movies'); 

  % remove blanks only from the test portion for each selector in
  % the cross validation group
  snames = find_group(subj, 'selector', 'movies_xval');
  for s = 1:numel(snames)

    % get the matrices for our blanks and the cross validation selector
    blanksmat = get_mat(subj, 'selector', 'movies_noblank');
    selmat = get_mat(subj, 'selector', snames{s});

    % remove blanks from the test phase, not the training phase
    selmat( find(selmat==2 & blanksmat==0) ) = 0;
  
    subj = set_mat(subj, 'selector', snames{s}, selmat);
  end
 
end

% get the list of each regressor we're going to use
rnames = find_group(subj, 'regressors', 'baseregs_grp');

% loop through this list
for r = 1:numel(rnames)

  % extract the regressor name, and create from it a name for our
  % new statmap pattern
  regsname = rnames{r};
  statname = sprintf('stat_%s', regsname);  

  % calculate all statmaps without peeking
  subj = feature_select(subj, 'epi_z', regsname, 'movies_xval', ...
                        'statmap_funct', 'statmap_xcorr', ...
                        'statmap_arg', [], ...
                        'new_map_patname', ['stat_' regsname], ...
                        'thresh', []);

  % create a sorted mask of N voxels for this regressor, where N is
  % a parameter determined earlier through a parameter search
  subj = create_sorted_mask(subj, statname, regsname, default_params.N(r));
  
end

fprintf('Preprocessing completed.\n');
