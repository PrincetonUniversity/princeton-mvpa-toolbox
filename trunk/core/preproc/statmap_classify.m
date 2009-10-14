function [val scratch] = statmap_classify(pat,regs,scratch)

% Create a statmap based on cross-validation performance
%
% [VAL SCRATCH] = STATMAP_CLASSIFY(PAT,REGS,SCRATCH)
%
% This contains the logic for running classification on each
% voxel/sphere and creates a statmap of their
% results. Should work equally for a single voxel or bag of
% voxels. More or less reproduces the logic of
% cross-validation for this pat and this regs.
%
% This isn't designed to be called directly. Instead, use
% statmap_searchlight and specify that you want to use this
% as the objective function. You'll need to set the
% statmap_searchlight 'scratch' argument to contain the
% following:
%
% PAT3 (required). Contains the pattern timepoints that were
% marked with 3s in the SELNAME selector passed to
% FEATURE_SELECT. These are the validation timepoints
% that we're going to be testing on.
%
% REGS3 (required). As per PAT3
%
% CLASS_ARGS (required). Will be fed into the train and
% test functions, exactly as in cross_validation.
%
% PERFMET_NAME (required). Which performance metric to
% use, e.g. 'perfmet_maxclass'. You can only specify one.
%
% PERFMET_ARGS (required). Can be empty.

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


pat3 = scratch.pat3;
regs3 = scratch.regs3;

[nConds nTimepoints] = size(regs3);
nVox = scratch.nVox;

class_args = scratch.class_args;
perfmet_funct= scratch.perfmet_funct;
perfmet_args = scratch.perfmet_args;

% train and test the classifier
train_funct_hand = str2func(class_args.train_funct_name);
class_scratch = train_funct_hand(pat,regs,class_args,[]);

test_funct_hand = str2func(class_args.test_funct_name);
[acts class_scratch] = test_funct_hand(pat3,regs3,class_scratch);

% check whether we have already created a 3D MULTI_ACTS field to
% store the activations from each sphere's classifier. if we have,
% place our ACTS for the latest sphere in the right place in
% MULTI_ACTS. if we haven't, then create a MULTI_ACTS matrix of the
% right size.
%
% this complicated procedure is required because STATMAP_SEARCHLIGHT
% (our caller function) doesn't know that we need an ACTS matrix
if ~isfield(scratch,'multi_acts')
  % MULTI_ACTS field doesn't exist, so create it
  scratch.multi_acts = NaN(nVox,nConds,nTimepoints);  
end % created ACTS field
scratch.multi_acts(scratch.v_counter,:,:) = acts;

% place our latest nConds x nTimepoints ACTS in the right part of the
% MULTI_ACTS 3D nVox x nConds x nTimepoints matrix

perfmet_funct_hand = str2func(perfmet_funct);
perfmet = perfmet_funct_hand(acts,regs3,class_scratch, ...
                             perfmet_args);

% keep appending the the latest classifier scratch information from
% the most recent time STATMAP_CLASSIFY was run
if ~isfield(scratch,'class_scratch')
  scratch.class_scratch = class_scratch;
else
  scratch.class_scratch(end+1) = class_scratch;
end

val = perfmet.perf;

if isnan(val)
  warning('Val is NaN')
end

