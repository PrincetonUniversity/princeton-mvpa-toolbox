function [subj results] = tutorial_easy()

% Tutorial script to accompany TUTORIAL_EASY.HTM
%
% [SUBJ RESULTS] = TUTORIAL_EASY()
%
% This is the sample script for the Haxby et al. (Science, 2001) 8-
% categories study. See the accompanying TUTORIAL_EASY.HTM, the
% MVPA manual (MANUAL.HTM) and then TUTORIAL_HARD.HTM.

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


% Check to make sure the Neuralnetwork toolbox is in the path or this
% won't work.
if ~exist('newff') %#ok<EXIST>
    error('This tutorial requires the neural networking toolbox, if it is unavailable this will not execute');
end
    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INITIALIZING THE SUBJ STRUCTURE

% start by creating an empty subj structure
subj = init_subj('haxby8','tutorial_subj');

%%% create the mask that will be used when loading in the data
subj = load_afni_mask(subj,'VT_category-selective','mask_cat_select_vt+orig');

% now, read and set up the actual data. load_AFNI_pattern reads in the
% EPI data from a BRIK file, keeping only the voxels active in the
% mask (see above)
for i=1:10
  raw_filenames{i} = sprintf('haxby8_r%i+orig',i);
end
subj = load_afni_pattern(subj,'epi','VT_category-selective',raw_filenames);

% initialize the regressors object in the subj structure, load in the
% contents from a file, set the contents into the object and add a
% cell array of condnames to the object for future reference
subj = init_object(subj,'regressors','conds');
load('tutorial_regs');
subj = set_mat(subj,'regressors','conds',regs);
condnames = {'face','house','cat','bottle','scissors','shoe','chair','scramble'};
subj = set_objfield(subj,'regressors','conds','condnames',condnames);

% store the names of the regressor conditions
% initialize the selectors object, then read in the contents
% for it from a file, and set them into the object
subj = init_object(subj,'selector','runs');
load('tutorial_runs');
subj = set_mat(subj,'selector','runs',runs);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PRE-PROCESSING - z-scoring in time and no-peeking anova

% we want to z-score the EPI data (called 'epi'),
% individually on each run (using the 'runs' selectors)
subj = zscore_runs(subj,'epi','runs');

% now, create selector indices for the n different iterations of
% the nminusone
subj = create_xvalid_indices(subj,'runs');

% run the anova multiple times, separately for each iteration,
% using the selector indices created above
[subj] = feature_select(subj,'epi_z','conds','runs_xval');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CLASSIFICATION - n-minus-one cross-validation

% set some basic arguments for a backprop classifier
class_args.train_funct_name = 'train_bp';
class_args.test_funct_name = 'test_bp';
class_args.nHidden = 0;

% now, run the classification multiple times, training and testing
% on different subsets of the data on each iteration
[subj results] = cross_validation(subj,'epi_z','conds','runs_xval','epi_z_thresh0.05',class_args);














