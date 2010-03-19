function [errs warns] = spm_test_omnibus(varargin)

% [errs,warns] = UNIT_SPM_RUNALL(varargin)
% This function simply calls the entirety of the SPM unit tests creating a
% monolithic script that you can run to test everything in one shot
% instead of running them all seperately.
%
% FEXTENSION(*.nii/.img)
% If unset, this will assume you wish to run the tutorial against nifti
% data.  If set to .img it will change to using the analyze data set.
%
%
%% Required Fields:
% There are no required fields for this function to run.
%
%% Options:
% There are no optional fields for this function.
%
%
%% License:
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DEFAULTS
% Before we get started we need to setup a single default.
defaults.fextension = '.nii';
defaults.single = 'false';
global single


args = propval(varargin,defaults);

if (isfield(args,'fextension'))
    fextension=args.fextension;
else
    fextension=defaults.fextension;
end

if (isfield(args,'single'))
    single = args.single;
else
    single = defaults.single;
end

%% Load up errs and warns so that they you know... work
errs = {};
warns = {};




%% Run Functional Tests One by One and populate errs/warns.

% run basic spm ana test
[errs{end+1} warns{end+1}] = unit_spm_ana('fextension',fextension,'single',single);

% run the tutorial comparison
[errs{end+1} warns{end+1}] = unit_spm_afni_tutcompare('fextension',fextension,'single',single);

% run afni compare
[errs{end+1} warns{end+1}] = unit_spm_ana_afnicompare('fextension',fextension,'single',single);

% haxby data compare
[errs{end+1} warns{end+1}] = unit_spm_ana_haxby_dat_compare('fextension',fextension,'single',single);

%cell array tests
[errs{end+1} warns{end+1}] = unit_spm_cellarrayfilename_load('fextension',fextension,'single',single);


end
