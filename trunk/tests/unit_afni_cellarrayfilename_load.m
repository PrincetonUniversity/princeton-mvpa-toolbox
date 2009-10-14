function [errs warns] = unit_afni_cellarrayfilename_load()

% [ERRS WARNS] = UNIT_TEMPLATE()
%
% This is the template for a unit test. Unit tests should
% take in no arguments (or only varargin optional
% arguments), and return ERRS and WARNS cell arrays of
% error messages. If both are empty, the test has passed.
%
% The unit test should ideally be completely
% self-contained. If you need fake data to run it on, then
% generate synthetic data yourself. If you need real sample
% data, then we can maybe add a few small sample data files
% to this directory.
%
% The idea is that you can completely automate the running
% of unit tests using the RUN_TESTS function. However, while
% you're coding the unit test, you might find the
% ALERT_UNIT_ERRORS function useful for interactive feedback
% on how an individual test is doing.
%
% The main bits that you have to edit are marked with TODO,
% though it's worth reading through the whole function
% first.
%
% ERRS = cell array holding the error strings
% describing any tests that failed. If this is empty,
% that's a good thing.
%
% WARNS = cell array, like ERRS, of tests that didn't
% pass and didn't fail (e.g. because they couldn't be run
% for some reason). Again, empty is good. N.B. in practice,
% we don't use warnings very much.


% initialize the variables that are going to keep track of
% the status of things. ideally, they'll be pristine at the
% end of all our tests, indicating success
errs = {};
warns = {};

% We're going to put all the individual tests in their own
% functions. Besides being neat, this serves a purpose,
% because it forces you to recreate all your variables from
% scratch each test. Otherwise, there's a possibility that
% your tests might be reusing an existing variable, and not
% testing what you think they're testing. Just make sure to
% remember to call all the test functions...
[errs warns] = check_for_MVPA(errs, warns);
[errs warns] = test1(errs, warns);
[errs warns] = test2(errs, warns);
[errs warns] = test3(errs, warns);
[errs warns] = test4(errs, warns);
[errs warns] = test5(errs, warns);
[errs warns] = test6(errs, warns);

[errs warns] = test7(errs, warns);
[errs warns] = test8(errs, warns);
[errs warns] = test9(errs, warns);



[errs warns] = alert_unit_errors(errs,warns);


end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [errs warns] = check_for_MVPA(errs,warns)

% Check that we have everything we need to run the test.

% TODO: if there are cases where you're not able to run your
% tests, might as well just flag these as warnings
    if ~exist('tutorial_easy') %#ok<EXIST>
        warns{end+1} = 'afni_cellarrayfilename_load(setup):MVPA toolbox is not in the path - won''t be able to run remaining tests';

        % if that requirement was critical for your tests, you
        % might as well just exit now, and avoid the inevitable
        % error. that way, the rest of your unit tests can still
        % be run
        return

    end
end

%% tests that should not throw an error.


function [errs warns] = test1(errs, warns)

    try
        subj = init_subj('test','test_subj');
        subj = load_afni_mask(subj,'test_mask','mask_cat_select_vt+orig.BRIK');
        subj = load_afni_pattern(subj,'epi_test','test_mask',{'concat_hax+orig.BRIK' 'haxby8_r1+orig.BRIK'}); %#ok<NASGU>
        clear subj;

    catch
        errs{end+1} = 'afni_cellarrayfilename_load(1):load_afni_pattern failed to open two files of dissimilar length';
    end
end

function [errs warns] = test2(errs, warns)

    try
        subj = init_subj('test','test_subj');
        subj = load_afni_mask(subj,'test_mask','mask_cat_select_vt+orig.BRIK');
        subj = load_afni_pattern(subj,'epi_test','test_mask',{'haxby8_r2+orig.BRIK' 'haxby8_r1+orig.BRIK' 'haxby8_r3+orig.BRIK'}); %#ok<NASGU>
        clear subj;


    catch
        errs{end+1} = 'afni_cellarrayfilename_load(2):load_afni_pattern failed to open two files of the same length';

    end
end

function [errs warns] = test3(errs, warns)

    try
        subj = init_subj('test','test_subj');
        subj = load_afni_mask(subj,'test_mask','mask_cat_select_vt+orig.BRIK');
        subj = load_afni_pattern(subj,'epi_test','test_mask',{'haxby8_r1+orig.BRIK' 'haxby8_r2+orig.BRIK' 'concat_hax+orig.BRIK'}); %#ok<NASGU>
        clear subj;


    catch
        errs{end+1} = 'afni_cellarrayfilename_load(3):load_afni_pattern failed to open two files of simmilar and dissimilar lengths';

    end
end

function [errs warns] = test4(errs, warns)

    try
        subj = init_subj('test','test_subj');
        subj = load_afni_mask(subj,'test_mask','mask_cat_select_vt+orig.BRIK');
        subj = load_afni_pattern(subj,'epi_test1','test_mask',{'haxby8_r1+orig.BRIK'}); 
        subj = load_afni_pattern(subj,'epi_test2','test_mask',{'concat_hax+orig.BRIK'}); %#ok<NASGU>
        clear subj;


    catch
        errs{end+1} = 'afni_cellarrayfilename_load(4):load_afni_pattern failed to open two files of dissimilar lengths as seperate patterns.';

    end
end

function [errs warns] = test5(errs, warns)

    try
        subj = init_subj('test','test_subj');
        subj = load_afni_mask(subj,'test_mask','mask_cat_select_vt+orig.BRIK');
        subj = load_afni_pattern(subj,'epi_test1','test_mask',{'haxby8_r1+orig.BRIK' 'haxby8_r2+orig.BRIK'}); 
        subj = load_afni_pattern(subj,'epi_test2','test_mask',{'concat_hax+orig.BRIK'}); %#ok<NASGU>
        clear subj;


    catch
        errs{end+1} = 'afni_cellarrayfilename_load(5):load_afni_pattern failed to open two files of simmilar lengths with a dissimilar length as second pattern.';

    end
end

function [errs warns] = test6(errs, warns)

    try
        subj = init_subj('test','test_subj');
        subj = load_afni_mask(subj,'test_mask','mask_cat_select_vt+orig.BRIK');
        subj = load_afni_pattern(subj,'epi_test1','test_mask',{'haxby8_r1+orig.BRIK' }); 
        subj = load_afni_pattern(subj,'epi_test2','test_mask',{'concat_hax+orig.BRIK' 'haxby8_r2+orig.BRIK'}); %#ok<NASGU>
        clear subj;


    catch
        errs{end+1} = 'afni_cellarrayfilename_load(6):load_afni_pattern failed to open two files of dissimilar lengths with a second pattern.';

    end
end

%% tests that should error out

function [errs warns] = test7(errs, warns)

    try
        subj = init_subj('test','test_subj');
        subj = load_afni_mask(subj,'test_mask','mask_cat_select_vt+orig.BRIK');
        subj = load_afni_pattern(subj,'epi','test_mask'); %#ok<NASGU>
        errs{ends+1} = 'afni_cellarrayfilename_load(7):did not fail with missing file name.';        
        clear subj;
    catch
        
    end

end

function [errs warns] = test8(errs, warns)

    try
        subj = init_subj('test','test_subj');
        subj = load_afni_mask(subj,'test_mask','mask_cat_select_vt+orig.BRIK');
        subj = load_afni_pattern(subj,'epi',{'haxby8_r1+orig.BRIK' }); %#ok<NASGU>
        errs{ends+1} = 'afni_cellarrayfilename_load(8):did not fail with missing mask name.';        
        clear subj;
    catch
        
    end

end

function [errs warns] = test9(errs, warns)

    try
        subj = init_subj('test','test_subj');
        subj = load_afni_mask(subj,'test_mask','mask_cat_select_vt+orig.BRIK');
        subj = load_afni_pattern(subj,'test_mask',{'haxby8_r1+orig.BRIK' }); %#ok<NASGU>
        errs{ends+1} = 'afni_cellarrayfilename_load(9):did not fail with missing pattern name';
        clear subj;
        
    catch
        
    end

end