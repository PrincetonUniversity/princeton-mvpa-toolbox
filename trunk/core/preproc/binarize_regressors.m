function [subj new_regsname] = binarize_regressors(subj,old_regsname,thresh,varargin)

% [SUBJ NEW_REGSNAME] = BINARIZE_REGRESSORS(SUBJ,OLD_REGSNAME,THRESH, ...)
%
% Takes in a regressors object, and sets all values below THRESH to 0,
% and all values above THRESH to 1.
%
% Gets called by CONVOLVE_REGRESSORS_AFNI.
%
% NEW_REGSNAME (optional, default = sprintf('%s_thr',old_regsname)).


% e.g. 'blah_conv' -> 'blah_conv_thr0.8'
defaults.new_regsname = sprintf('%s_thr%.1f',old_regsname,thresh);
args = propval(varargin,defaults);
args_into_workspace

[subj regs] = duplicate_object(subj,'regressors',old_regsname,new_regsname);

% create a zeros matrix, then put 1s in wherever the
% convolve regressor values are above the BINARIZE_THRESH
regs_thr = zeros(size(regs));
set_to_one_idx = find(regs > thresh);
regs_thr(set_to_one_idx) = 1;
% now, set the thresholded version in the SUBJ
subj = set_mat(subj,'regressors',new_regsname,regs_thr);

created.function = mfilename;
created.old_regsname = old_regsname;
created.thresh = thresh;
created.args = args;
subj = add_created(subj,'regressors',new_regsname,created);
