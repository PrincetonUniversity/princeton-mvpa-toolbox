function [errs warns] = unit_spm_cellarrayfilename_load(varargin)

% [ERRS WARNS] = UNIT_SPM_CELLARRAYFILENAME_LOAD(varargin)
%
% This is a series of general Unit tests for the spm load commands.  It
% tests a variety of files of varying sizes to make sure the behvaiors are
% within expectations. 
%
% FEXTENSION('.nii'/'.img')
% If unset, this will assume you wish to run the tutorial against nifti
% data.  If set to '.img' it will change to using the analyze data set.
%
%
% ERRS = cell array holding the error strings describing any tests that
% failed. If this is empty, that's a good thing.
%
% WARNS = cell array, like ERRS, of tests that didn't pass and didn't fail
% (e.g. because they couldn't be run for some reason). Again, empty is
% good. N.B. in practice, we don't use warnings very much.


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
% initialize the variables that are going to keep track of the status of
% things. ideally, they'll be pristine at the end of all our tests,
% indicating success
errs = {};
warns = {};

if strcmp(fextension,'')

        [errs{end+1} warns{end+1}] = unit_spm_cellarrayfilename_load('fextension','.nii');
        [errs{end+1} warns{end+1}] = unit_spm_cellarrayfilename_load('fextension','.img');
    return;
    
end



% We're going to put all the individual tests in their own functions.
% Besides being neat, this serves a purpose, because it forces you to
% recreate all your variables from scratch each test. Otherwise, there's a
% possibility that your tests might be reusing an existing variable, and
% not testing what you think they're testing. Just make sure to remember to
% call all the test functions...
[errs warns] = check_for_MVPA(errs, warns);
[errs warns] = test1(errs, warns, fextension,single);
[errs warns] = test2(errs, warns, fextension,single);
[errs warns] = test3(errs, warns, fextension,single);
[errs warns] = test4(errs, warns, fextension,single);
[errs warns] = test5(errs, warns, fextension,single);
[errs warns] = test6(errs, warns, fextension,single);

[errs warns] = test7(errs, warns, fextension,single);
[errs warns] = test8(errs, warns, fextension,single);
[errs warns] = test9(errs, warns, fextension,single);



[errs warns] = alert_unit_errors(errs,warns);


end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [errs warns] = check_for_MVPA(errs,warns)

% Check that we have everything we need to run the test.

% TODO: if there are cases where you're not able to run your tests, might
% as well just flag these as warnings
%     if ~exist('tutorial_easy') %#ok<EXIST>
%         warns{end+1} = 'spm_cellarrayfilename_load(setup):MVPA toolbox is not in the path - won''t be able to run remaining tests';
%
%         % if that requirement was critical for your tests, you might as
%         % well just exit now, and avoid the inevitable error. that way, the
%         % rest of your unit tests can still be run
%         return
%     else
if ~exist('spm_vol') %#ok<EXIST>
    warns{end+1} = 'spm_cellarrayfilename_load(setup):SPM toolbox is missing, unit_spm tests will not function';
    return
end
end

%% tests that should not throw an error.


function [errs warns] = test1(errs, warns, fextension,single)

    try
        subj = init_subj('test','test_subj');
        subj = load_spm_mask(subj,'test_mask',['mask_cat_select_vt' fextension]);
        subj = load_spm_pattern(subj,'epi_test','test_mask',{['concat_hax' fextension] ['haxby8_r1' fextension]},'single',single); %#ok<NASGU>
        clear subj;
    catch
        errs{end+1} = 'spm_cellarrayfilename_load(1):load_spm_pattern failed to open two files of disimilar length';
    end
end

function [errs warns] = test2(errs, warns, fextension,single)

    try
        subj = init_subj('test','test_subj');
        subj = load_spm_mask(subj,'test_mask',['mask_cat_select_vt' fextension]);
        subj = load_spm_pattern(subj,'epi_test','test_mask',{['haxby8_r2' fextension] ['haxby8_r1' fextension] ['haxby8_r3' fextension]},'single',single); %#ok<NASGU>
        clear subj;


    catch
        errs{end+1} = 'spm_cellarrayfilename_load(2):load_spm_pattern failed to open two files of the same length';

    end
end

function [errs warns] = test3(errs, warns, fextension,single)

    try
        subj = init_subj('test','test_subj');
        subj = load_spm_mask(subj,'test_mask',['mask_cat_select_vt' fextension]);
        subj = load_spm_pattern(subj,'epi_test','test_mask',{['haxby8_r1' fextension] ['haxby8_r2' fextension] ['concat_hax' fextension]},'single',single); %#ok<NASGU>
        clear subj;


    catch
        errs{end+1} = 'spm_cellarrayfilename_load(3):load_spm_pattern failed to open two files of similar and disimilar lengths';

    end
end

function [errs warns] = test4(errs, warns, fextension,single)

    try
        subj = init_subj('test','test_subj');
        subj = load_spm_mask(subj,'test_mask',['mask_cat_select_vt' fextension]);
        subj = load_spm_pattern(subj,'epi_test1','test_mask',{['haxby8_r1' fextension]},'single',single); 
        subj = load_spm_pattern(subj,'epi_test2','test_mask',{['concat_hax' fextension]},'single',single); %#ok<NASGU>
        clear subj;


    catch
        errs{end+1} = 'spm_cellarrayfilename_load(4):load_spm_pattern failed to open two files of disimilar lengths as separate patterns.';

    end
end

function [errs warns] = test5(errs, warns, fextension,single)

    try
        subj = init_subj('test','test_subj');
        subj = load_spm_mask(subj,'test_mask',['mask_cat_select_vt' fextension]);
        subj = load_spm_pattern(subj,'epi_test1','test_mask',{['haxby8_r1' fextension] ['haxby8_r2' fextension]},'single',single); 
        subj = load_spm_pattern(subj,'epi_test2','test_mask',{['concat_hax' fextension]},'single',single); %#ok<NASGU>
        clear subj;


    catch
        errs{end+1} = 'spm_cellarrayfilename_load(5):load_spm_pattern failed to open two files of similar lengths with a disimilar length as second pattern.';

    end
end

function [errs warns] = test6(errs, warns, fextension,single)

    try
        subj = init_subj('test','test_subj');
        subj = load_spm_mask(subj,'test_mask',['mask_cat_select_vt' fextension]);
        subj = load_spm_pattern(subj,'epi_test1','test_mask',{['haxby8_r1' fextension] },'single',single); 
        subj = load_spm_pattern(subj,'epi_test2','test_mask',{['concat_hax' fextension] ['haxby8_r2' fextension]},'single',single); %#ok<NASGU>
        clear subj;


    catch
        errs{end+1} = 'spm_cellarrayfilename_load(6):load_spm_pattern failed to open two files of disimilar lengths with a second pattern.';

    end
end

%% tests that should error out

function [errs warns] = test7(errs, warns, fextension,single)

    try
        subj = init_subj('test','test_subj');
        subj = load_spm_mask(subj,'test_mask',['mask_cat_select_vt' fextension]);
        subj = load_spm_pattern(subj,'epi','test_mask','single',single); %#ok<NASGU>
        errs{ends+1} = 'spm_cellarrayfilename_load(7):did not fail with missing file name.';        
        clear subj;
    catch %#ok<CTCH>
        
    end

end

function [errs warns] = test8(errs, warns, fextension,single)

    try
        subj = init_subj('test','test_subj');
        subj = load_spm_mask(subj,'test_mask',['mask_cat_select_vt' fextension]);
        subj = load_spm_pattern(subj,'epi',{['haxby8_r1' fextension] },'single',single); %#ok<NASGU>
        errs{ends+1} = 'spm_cellarrayfilename_load(8):did not fail with missing mask name.';        
        clear subj;
    catch %#ok<CTCH>
        
    end

end

function [errs warns] = test9(errs, warns, fextension,single)

    try
        subj = init_subj('test','test_subj');
        subj = load_spm_mask(subj,'test_mask',['mask_cat_select_vt' fextension]);
        subj = load_spm_pattern(subj,'test_mask',{['haxby8_r1.' fextension]},'single',single); %#ok<NASGU>
        errs{ends+1} = 'spm_cellarrayfilename_load(9):did not fail with missing pattern name';
        clear subj;
        
    catch %#ok<CTCH>
        
    end

end