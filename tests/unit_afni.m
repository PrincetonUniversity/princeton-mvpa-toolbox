function [errs warns] = unit_afni(errs, warns)

% [ERRS WARNS] = UNIT_AFNI()
%
% This is a unit test for the SPM ANALYZE import/export
% functions, LOAD_ANALYZE_MASK.M, LOAD_ANALYZE_PATTERN and
% WRITE_TO_ANALYZE.M.
%
% It requires several data files to function properly, which
% it loads and writes out in various ways, using the
% originals as an initial basis for comparison and a
% starting point. Basically, it reads in an AFNI file,
% writes it out, reads it back in, and compares its first
% and second version. This round-tripping should pick up any
% major problems, especially in the writing.
%
%
% Requirements to run:
%
% - standard MVPA toolbox functions
%
% - LOAD_AFNI_MASK.M, LOAD_AFNI_PATTERN and
% WRITE_TO_AFNI.M
%
% - Ziad Saad's afni_matlab library
%


%errs = {};
%warns = {};

verbose = true;
% the below are simply error checking to make sure you
% actually have the required packages installed.
if ~exist('tutorial_easy') %#ok<EXIST>
  warns{end+1} = 'MVPA toolbox is not in the path - won''t be able to run remaining tests';
  return
end

% First we will load up the data structure that is going to
% hold our source and destination file names. If you add
% more data sets to the end of the data folder or remove
% some you will have to change this loop to account for
% that.

if verbose
  disp('Generating file names, creating test directory')
end

base_padding = 3;
filecount=10;
for i=1:filecount
  %tmp(1:base_padding)='0';
  s_index=num2str(i);
  %tmp(end-length(s_index)+1:end)=s_index;
  tmp = s_index;
  
  raw_source_filenames{i}=['haxby8_r' tmp '+orig']; %#ok<AGROW>
  %raw_destination_filenames{i}=['testwork/utest_' tmp '+orig.BRIK'];
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
%mask_subj = load_analyze_mask(mask_subj, 'ana_mask','mask_cat_select_vt+orig.BRIK','beta_defaults','true');
mask_subj = load_afni_mask(mask_subj, 'ana_mask','mask_cat_select_vt+orig');
%save mask
write_to_afni(mask_subj, 'mask','ana_mask','mask_cat_select_vt+orig','output_filename','testwork/utest_mask_');

% now to check the data from the first mask and second mask
% against each other to make sure they're the same
if verbose
  disp('Two file comparison')
end

mask_subj_2 = init_subj('unit_test', 'spm_ana');
mask_subj_2 = load_afni_mask(mask_subj_2, 'ana_mask','testwork/utest_mask_+orig.BRIK');
data1 = get_mat(mask_subj, 'mask','ana_mask');
data2 = get_mat(mask_subj_2,'mask','ana_mask');

if (not(isequal(data1,round(data2))))
  errs(end+1) = 'AFNI_LOAD/WRITE: Data loaded, then saved and loaded again is not equal (mask,rounded)';
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
  %keyboard;
  [junk, head_info] = BrikInfo(raw_source_filenames{n});
  % this is the size of the temporary mask we're going to
  % have to create in order to load in the pattern
  mask_dims = head_info.DATASET_DIMENSIONS(1:3);
  % clear the nifti data reference so it's not occupying
  % memory

  clear junk;
  clear head_info;
    
  % generate the mask. this will allow all the voxels in the
  % pattern through
  temp_mask=ones(mask_dims);
  
  %create temporary SUBJ structures and load in the mask
  temp_subj_001 = init_subj('unit_test', 'afni');
  temp_subj_001 = initset_object(temp_subj_001, 'mask','afni_mask', temp_mask);
  
  temp_subj_002 = init_subj('unit_test', 'afni');
  temp_subj_002 = initset_object(temp_subj_002, 'mask','afni_mask', temp_mask);

  % load the pattern the first time
  
  temp_subj_001=load_afni_pattern(temp_subj_001, 'afni_brain', 'afni_mask', raw_source_filenames{n});
  %and write it back out.
  write_to_afni(temp_subj_001,'pattern','afni_brain',raw_source_filenames{n},'output_filename',['testwork/utest_' num2str(n) '_' ]);

  temp_subj_002=load_afni_pattern(temp_subj_002, 'afni_brain','afni_mask',['testwork/utest_' num2str(n) '_+orig']); 
  data1 = get_mat(temp_subj_001,'pattern','afni_brain');

  data2 = get_mat(temp_subj_002,'pattern','afni_brain');
   
  
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Loading multiple files into a single sub structure and saving them back
%out.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INITIALIZING THE SUBJ STRUCTURE


base_padding = 3;
% start by creating an empty subj structure
subj = init_subj('haxby8','tutorial_subj');

%%% create the mask that will be used when loading in the data
subj = load_afni_mask(subj,'VT_category-selective','mask_cat_select_vt+orig.BRIK');

% now, read and set up the actual data. load_AFNI_pattern reads in the
% EPI data from a BRIK file, keeping only the voxels active in the
% mask (see above)
for i=1:1
    index=num2str(i);
  raw_filenames{i} = ['haxby8_r' index '+orig.BRIK'];
end
subj = load_afni_pattern(subj,'epi','VT_category-selective',raw_filenames);
%keyboard;
write_to_afni(subj,'pattern','epi','mask_cat_select_vt+orig','output_filename','testwork/utest2_');

% clean up.
rmdir ('testwork','s');

