function [errs warns] = unit_spm_ana_afnicompare(varargin)

% [ERRS WARNS] = UNIT_SPM_ANA_AFNICOMPARE(varargin)
%
% Unit test of the spm ana files in comparison to the afni brik version of
% those same files.
%
%
% FEXTENSION(*.nii/.img)
% If unset, this will assume you wish to run the tutorial against nifti
% data.  If set to .img it will change to using the analyze data set.
%
% The only files that are necessary for this test are the afni matlab
% libraries, the spm5 library and the unit test data files.  Specifically
% from the data you need unit_002.hdr/img - unit_005 and the associated
% brik/head files.

% ERRS = cell array holding the error strings
% describing any tests that failed. If this is empty,
% that's a good thing.
%
% WARNS = cell array, like ERRS, of tests that didn't
% pass and didn't fail (e.g. because they couldn't be run
% for some reason). Again, empty is good. N.B. in practice,
% we don't use warnings very much

% Requirements to run:
% - SPM5
% - mvpa and all other associated dependencies (this includes the afni
% libraries as they are used extensively throughout the code).
% - unit_set data folder.
%
% The afni data used in this test was created from the corresponding SPM
% test data using the afni 3dcopy command with no flags or special
% commands.

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

errs = {};
warns = {};

if strcmp(fextension,'')

        [errs{end+1} warns{end+1}] = unit_spm_ana_afnicompare('fextension','.nii');
        [errs{end+1} warns{end+1}] = unit_spm_ana_afnicompare('fextension','.img');
    return;
    
end



%start up the spm system with default settings.
%spm_defaults;

%first we will set this, as this controls alot of the textual feedbak
%you'll recieve throughout the document.
verbose = true;
%check for the exsistence of mvpa and the default tutorial included with
%it.  MVPA should be in your systems default path.

if verbose
    disp('Dependency tests.')
end

if ~exist('tutorial_easy')
    warns{end+1} = 'MVPA toolbox is not in the path - won''t be able to run remaining tests';
    return
end
%check for the exsistence of SPM5 in your default path.
if ~exist('spm5')
    warns{end+1} = 'spm5 toolbox is not in the path - this package will not work without this toolbox';
    return
end
%and finally the star of this little show, afni.
if ~exist('BrikLoad')
    warns{end+1} = 'Afni Matlab Library is missing - this package will not work without this toolbox';
    return
end
%
%if either of these checks fail fatally as continuning would be entirely
%meaningless as it would fail immediately.
%
% first we'll load the file names we'll be accessing, these are hard coded
% because the data is unlikely to ever change.  If this changes in the
% future this code block can be changed to account for the issue.

% first specify the prefix that the data is being stored under. this will
% allow the data to be moved about with relative ease.  - this may be
% extracted out to a variable that can be delivered to the function at
% somepoint in the future.

%i'm doing this in a fairly 'dirty' manner because we are only testing a
%few files with no mentioned plans to expand those file sets.

if verbose
    disp('Loading file names into spm_file_names and afni_file_names.')
end

for i=1:12
    index=num2str(i);
    tmp(1:3)='0';
    %keyboard;
    tmp(end-length(index)+1:end)=index;
    spm_file_names{i} = ['unit_' tmp fextension];
    afni_file_names{i} = ['unit_' tmp '+orig'];
end

for n=1:12

    % List of variables that must be cleared before the loop runs again:
    % - nifti_dat
    % - mask_dims
    % - temp_mask
    % - temp_subj_001
    % - temp_subj_002
    % - data1
    % - data2
    % -


    if verbose
        dispf('Index: %d',n);
    end

    % figure out the dimensions of the mask we're about to
    % load in, so we can preinitialize the matrix. this reads
    % in the header information
    nifti_dat=nifti(spm_file_names{n});
    % this is the size of the temporary mask we're going to
    % have to create in order to load in the pattern
    mask_dims=size(nifti_dat.dat);
    % clear the nifti data reference so it's not occupying
    % memory
    clear nifti_dat;

    % generate the mask. this will allow all the voxels in the
    % pattern through
    temp_mask=ones(mask_dims);

    %create temporary SUBJ structures and load in the mask
    temp_subj_001=init_subj('unit_test', 'spm_ana');
    temp_subj_001=initset_object(temp_subj_001,'mask','spm_ana_mask',temp_mask);



    % load the pattern the first time
    temp_subj_001=load_spm_pattern(temp_subj_001, 'ana_brain','spm_ana_mask',spm_file_names{n},'single',single);
    %temp_subj_001=load_spm_pattern(temp_subj_001, 'ana_brain','spm_ana_mask',spm_file_names{n});
    temp_subj_001=load_afni_pattern(temp_subj_001, 'afni_brain','spm_ana_mask',afni_file_names{n},'single',single);

    data1 = get_mat(temp_subj_001,'pattern','ana_brain');

    data2 = get_mat(temp_subj_001,'pattern','afni_brain');

    ignored_nans = isnan(data1) | isnan(data2); %#ok<NASGU>



    if (abs(data1 - data2) > 1e-5)
        diffcd = data1 - data2;
        errs{end+1} = ['SPM_ANA_LOAD/WRITE: Data Comparison from spm to afni not equal. Index:' num2str(n) ...
            ', standard deviation from 0: ' num2str(std(diffcd)) ', mean: ' num2str(mean(diffcd))];


        if verbose
            dispf('Index: %d %s failed.',n,spm_file_names{n});
        end
    end

end

%      keyboard; %/debug code.
