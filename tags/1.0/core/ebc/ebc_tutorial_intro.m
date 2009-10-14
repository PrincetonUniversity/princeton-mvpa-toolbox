% Tutorial script for predicting the EBC data - "Introduction" Version
%
% This tutorial will guide you in a step-by-step fashion through some
% of the analysis necessary to recreate one of the Princeton EBC
% Team's submissions to the competition.  This tutorial is geared fro
% those who have never seen the MVPA toolbox before.  If you already
% feel perfectly comfortable setting up and running an experiment in
% the toolbox from start to finish, you will want to skim through this
% and then start the advanced tutorial (ebc_tutorial_adv.m).
% Please note: this script file is meant to be an accessory to the
% online tutorial, not a replacement.  If you haven't seen the
% online tutorial, please head to:
%
% http:/www.csbmb.princeton.edu/mvpa/ebc/ebc_tutorial_intro.html
% 
% This tutorial assumes you have downloaded all files required to
% install the MVPA toolbox and EBC extensions, as well as the
% tutorial EBC data for all three subjects.  For installation
% instructions, please see the online documentation:
%
% http://www.csbmb.princeton.edu/mvpa/ebc/install.html
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Step 1 - Create the subj structure with the EBC data.

% load the data matrix for subject 1
load 'tutorial_ebc1';

% Load the default parameters
load 'ebc_params.mat'
default_params = ebc_params{1, 3, 2};

% Initialize an empty subject, 'subject1', in experiment 'ebc'
subj = init_subj('ebc', 'subject1');

% Create a new mask from matrix wholebrain named 'wholebrain'
subj = initset_object(subj, 'mask', 'wholebrain', wholebrain);

% create a new pattern 'epi' from matrix epi, masked by 'wholebrain'
subj = initset_object(subj, 'pattern', 'epi', epi, 'masked_by', 'wholebrain');

% isolate the first thirteen regressors for use
baseregs = baseregs(1:13, :);
condnames = {condnames{1:13}};

% create a new regressors object, with the condition names associated
subj = initset_object(subj, 'regressors', 'baseregs', baseregs, ...
		      'condnames', condnames);

% create our selector objects to distinguish TRs by movie #
subj = initset_object(subj, 'selector', 'movies', movies);
subj = initset_object(subj, 'selector', 'movies_noblank', movies_noblank);

% SUMMARIZE() to print out the information on what we have just created.
summarize(subj);

% And we clean up the unneeded raw data we loaded just before:
clear epi baseregs movies movies_noblank condnames wholebrain;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Step 2 - Pre-processing.

% Detrend the pattern each run (movie) separately 
subj = apply_to_runs(subj, 'epi', 'movies', 'apply_detrend');

% Move the detrended pattern to the HD to save space
subj = move_pattern_to_hd(subj, 'epi');

% Z-score the pattern
subj = apply_to_runs(subj, 'epi_detrend', 'movies', 'apply_zscore', ...
                     'new_patname', 'epi_z');

% Move the no longer used detrended pattern to the HD to save RAM
subj = move_pattern_to_hd(subj, 'epi_detrend');

% Create the cross-validation selectors, so we can avoid peeking
% during the voxel selection phase
subj = create_xvalid_indices(subj, 'movies', 'actives_selname', ...
                             'movies_noblank');

% Separate the regressors matrix into thirteen separate regressors
subj = separate_regressors(subj, 'baseregs');

% Summarize again to check our progress
summarize(subj);

% Choose one of the regressors to analyze by a number; you can
% change this number if you want to use a different regressor.  
regsnum = 1;

regsnames = find_group(subj, 'regressors', 'baseregs_grp');
regsname = regsnames{regsnum};

% name the statmap "stat_<regsname>"
statname = ['stat_', regsname];

% Run feature selection: we use 'statmap_xcorr' to calculate cross
% correlation instead of the default classification based method,
% pass no arguments into it, and disable automatic threshold mask
% creation.  We also specify the name of the new pattern be
% 'stat_<regsname>' so we can identify it later.
subj = feature_select(subj, 'epi_z', regsname, 'movies_xval', ...
                      'statmap_funct', 'statmap_xcorr', ...
                      'statmap_arg', [], ...
                      'new_map_patname', statname, ...
                      'thresh', []);

% Create a mask group (one for each cross validation selector) of
% the "best" N voxels according to our statmap, named after the
% regressor.  We use a different N for each regressor, taken from
% the "optimal" parameter set:
N = default_params.N(regsnum);

maskname = regsname; 
subj = create_sorted_mask(subj, statname, maskname, N);

% summarize our progress one last time before the experiment
summarize(subj);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Step 3 - Optimizations 

% Perform spatial averaging, combining the activities of
% neighboring voxels within the cranium
subj = create_spatial_avg_pat(subj, 'epi_z', 'wholebrain');

% Move the old 'epi_z' pattern to HD to conserve ram
subj = move_pattern_to_hd(subj, 'epi_z');

% Temporal averaging - create an asymmetric box filter of size from the default parameters
filt = ones(1, default_params.time_average_window(regsnum));
filt = filt./sum(filt);

% Average the Z-scored and spatially filtered  voxels passed through our mask using this
% filter, and save the result in a new pattern named "epi_z_savg_filtered_<regsname>"
newpatname = ['epi_z_savg_tavg_', regsname];

subj = apply_to_runs(subj, 'epi_z_savg', 'movies', 'apply_filt', 'filt', filt, ...
                     'maskname', maskname, 'new_patname', newpatname);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Step 4 - Regression/Prediction - n-minus-one cross validation

% set up our training arguments: we're using ridge regression, with
% a penalty parameter taken from the "optimal" parameter set

class_args.train_funct_name = 'train_ridge';
class_args.test_funct_name = 'test_ridge';

% in general, the ridge regression penalty parameter should
% increase linearly with the number of voxels included in analysis
class_args.penalty = default_params.penalty(regsnum) * N;

% Perform the (n-1) cross validation experiment with our custom
% parameters:  
[subj results] = cross_validation(subj, newpatname, regsname, ...
                                 'movies_xval', ...
                                 maskname, ...
                                 class_args, ...
                                 'perfmet_functs', ...
                                 'perfmet_xcorr', ...
                                 'perfmet_args', {[]});



% This concludes the tutorial!
