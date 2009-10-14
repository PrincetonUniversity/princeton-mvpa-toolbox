function [errs warns] = unit_spm_ana()

% [ERRS WARNS] = UNIT_SPM_ANA()
%
% This is a unit test for the SPM ANALYZE import/export
% functions, LOAD_ANALYZE_MASK.M, LOAD_ANALYZE_PATTERN and
% WRITE_TO_ANALYZE.M.
%
% It requires several data files to function properly, which
% it loads and writes out in various ways, using the
% originals as an initial basis for comparison and a
% starting point. Basically, it reads in an ANALYZE file,
% writes it out, reads it back in, and compares its first
% and second version. This round-tripping should pick up any
% major problems, especially in the writing.
%
% Also it requires a file of the wrong
% format so that it can test the file based error checking
% of the system. ???
%
% ERRS = cell array holding the error strings
% describing any tests that failed. If this is empty,
% that's a good thing.
%
% WARNS = cell array, like ERRS, of tests that didn't
% pass and didn't fail (e.g. because they couldn't be run
% for some reason). Again, empty is good. N.B. in practice,
% we don't use warnings very much.
%
% Requirements to run:
%
% - standard MVPA toolbox functions
%
% - LOAD_ANALYZE_MASK.M, LOAD_ANALYZE_PATTERN and
% WRITE_TO_ANALYZE.M
%
% - Ziad Saad's afni_matlab library
%
% - SPM5


errs = {};
warns = {};

verbose = true;
% the below are simply error checking to make sure you
% actually have the required packages installed.
if ~exist('tutorial_easy')
  warns{end+1} = 'MVPA toolbox is not in the path - won''t be able to run remaining tests';
  return
end

if ~exist('spm5')
  warns{end+1} = 'spm5 toolbox is not in the path - this package will not work without this toolbox';
  return
end


% Testing basics - we want to ensure that a variety of files
% can be opened and resaved properly then we want to compare
% the inherent data of these files to ensure that these
% files are being created properly.

% First we will load up the data structure that is going to
% hold our source and destination file names. If you add
% more data sets to the end of the data folder or remove
% some you will have to change this loop to account for
% that.

if verbose
  disp('Generating file names, creating test directory')
end

base_padding = 3;
filecount=12;
for i=1:filecount
  tmp(1:base_padding)='0';
  s_index=num2str(i);
  tmp(end-length(s_index)+1:end)=s_index;
  
  raw_source_filenames{i}=['unit_' tmp '.img'];
  raw_destination_filenames{i}=['testwork/utest_' tmp '.img'];
end

% we need to create the folder we will be storing our work in. This will be
% deleted at the end of the script.
mkdir testwork;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Starting simply, we are just going to load a mask, save
% it, and load it - the two loaded versions should be
% identical

% create empty mask subj
mask_subj = init_subj('unit_test', 'spm_ana');

% load mask from file
%mask_subj = load_analyze_mask(mask_subj, 'ana_mask','mask_cat_select_vt.img','beta_defaults','true');
mask_subj = load_analyze_mask(mask_subj, 'ana_mask','mask_cat_select_vt.img');
%save mask
write_to_analyze(mask_subj, 'mask','ana_mask', 'output_filenames','testwork/utest_mask_', 'padding',base_padding);

% now to check the data from the first mask and second mask
% against each other to make sure they're the same
if verbose
  disp('Two file comparison')
end

mask_subj_2 = init_subj('unit_test', 'spm_ana');
%mask_subj_2 = load_analyze_mask(mask_subj_2, 'ana_mask','testwork/utest_mask_001.img','beta_defaults','true');
mask_subj_2 = load_analyze_mask(mask_subj_2, 'ana_mask','testwork/utest_mask_001.img');
data1 = get_mat(mask_subj, 'mask','ana_mask');
data2 = get_mat(mask_subj_2,'mask','ana_mask');

if (not(isequal(data1,round(data2))))
  errs(end+1) = 'SPM_ANA_LOAD/WRITE: Data loaded, then saved and loaded again is not equal (mask,rounded)';
  diffcd = data1 - data2;
end

clear mask_subj;
clear mask_subj_2;
clear data1;
clear data2;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ok now the meat of the tests.

if verbose
  disp('Starting Main Tests.')
end

for n=1:filecount
  if verbose
    dispf('Index: %d',n)
  end
  
  % figure out the dimensions of the mask we're about to
  % load in, so we can preinitialize the matrix. this reads
  % in the header information
  nifti_dat=nifti(raw_source_filenames{n});
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

  temp_subj_002=init_subj('unit_test', 'spm_ana');
  temp_subj_002=initset_object(temp_subj_002,'mask','spm_ana_mask',temp_mask);
  
  % load the pattern the first time
%  temp_subj_001=load_analyze_pattern(temp_subj_001, 'ana_brain','spm_ana_mask',raw_source_filenames{n},'beta_defaults','true');
  temp_subj_001=load_analyze_pattern(temp_subj_001, 'ana_brain','spm_ana_mask',raw_source_filenames{n}); 
  %and write it back out.
  write_to_analyze(temp_subj_001,'pattern','ana_brain','output_filenames',['testwork/utest_' num2str(n) '_' ],'padding',base_padding);
  
  % this happens due to the way files are saves the dest name
  % would be valid if they weren't individual files.
  %
  % what does this comment mean???
%  temp_subj_002=load_analyze_pattern(temp_subj_002, 'ana_brain','spm_ana_mask','testwork/utest_001.img','beta_defaults','true'); 
  temp_subj_002=load_analyze_pattern(temp_subj_002, 'ana_brain','spm_ana_mask',['testwork/utest_' num2str(n) '_001.img']); 
  data1 = get_mat(temp_subj_001,'pattern','ana_brain');
  
  data2 = get_mat(temp_subj_002,'pattern','ana_brain');
  
 ignored_nans = isnan(data1) | isnan(data2);

      
%   if (not(isequal(round(data1),round(data2))))
  if ((data1 - data2 > 1e-5) |(data1 - data2 < -1e-5)) 
    errs{end+1} = ['SPM_ANA_LOAD/WRITE: Data loaded, then saved and loaded again is not equal (mask,rounded) index: ' num2str(n)];
    diffcd = data1 - data2;
  end
  
  clear data1;
  clear data2;
  clear temp_subj_001;
  clear temp_subj_002;
  
end

% clean up.
rmdir ('testwork','s');

