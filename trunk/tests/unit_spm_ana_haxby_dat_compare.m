function [errs warns] = unit_spm_ana_haxby_dat_compare(varargin)

% Unit test for read and write to SPM
%
% [] = UNIT_SPM_ANA_HAXBY_DAT(varargin)
%
% This tests the quality of the information saved out vs. the original
% data.  It's meant to be geared towards the tutorial_easy_spm system.
% Specifically it's testing the value of data written out using the
% generate new header features of the write_to_spm script.  This MUST
% be executed from the unit_set folder.
%
% FEXTENSION(*.nii/.img)
% If unset, this will assume you wish to run the tutorial against nifti
% data.  If set to .img it will change to using the analyze data set.
%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DEFAULTS
% Before we get started we need to setup a single default.
defaults.fextension = '';
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

errs = [];
warns = [];

if strcmp(fextension,'')

        [errs{end+1} warns{end+1}] = unit_spm_ana_haxby_dat_compare('fextension','.nii');
        [errs{end+1} warns{end+1}] = unit_spm_ana_haxby_dat_compare('fextension','.img');
    return;
    
end

working_subj = tutorial_easy_spm();

mkdir 'testwork';
%keyboard;

write_to_spm(working_subj,'pattern','epi_z_anova_1','new_header','true','pathname','testwork','output_filename','anova_out','fextension',fextension);

working_subj=load_spm_pattern(working_subj,'epi_anova_compare','VT_category-selective',['testwork/anova_out' fextension],'single',single);



mainpat = get_mat(working_subj,'pattern','epi_z_anova_1');

comparepat = get_mat(working_subj,'pattern','epi_anova_compare');
keyboard;
if ~isequal(mainpat,comparepat)
    errs{end+1} = 'data does not compare properly, arbitrary header writeout failed.  This is normal for the single true flag.';
end


end