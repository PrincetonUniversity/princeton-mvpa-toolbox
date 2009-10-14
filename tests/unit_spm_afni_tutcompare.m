function [errs warns] = unit_spm_ana_afnicompare()

% [ERRS WARNS] = UNIT_SPM_ANA_AFNICOMPARE()
%
% Unit test of the spm ana files in comparison to the afni brik version of
% those same files.
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
% - mvpa and all other associated dependancies (this includes the afni
% libraries as they are used extensively throughout the code).
% - unit_set data folder.
%
% The afni data used in this test was created from the corresponding SPM
% test data using the afni 3dcopy command with no flags or special
% commands.

errs = {};
warns = {};

%start up the spm system with default settings.
%spm_defaults;

%first we will set this, as this controls alot of the textual feedbak
%you'll recieve throughout the document.
verbose = true;
%check for the exsistence of mvpa and the default tutorial included with
%it.  MVPA should be in your systems default path.

if verbose
  disp('Dependancy tests.')
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

[spm_subj spm_results] = tutorial_easy_spm;

[afni_subj afni_results] = tutorial_easy_afni;

if(not(isequal(spm_results.total_perf,afni_results.total_perf)));
	errs{end+1} = 'test failed';
end


%      keyboard; %/debug code.
