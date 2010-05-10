function [errs warns] = unit_scramble_regressors()

% [ERRS WARNS] = UNIT_SCRAMBLE_REGRESSORS()
% 
% This is a script that tests the SCRAMBLE_REGRESSORS function.
% It mainly tests the optional ACTIVE_SELNAME argument to exclude
% time points from being scrambled.
% INPUT ARGUMENTS:
% (none)
%
% OUTPUT ARGUMENTS:
% ERRS = cell array holding the error strings
% describing any tests that failed. If this is empty,
% that's a good thing.
%
% WARNS = cell array, like ERRS, of tests that didn't
% pass and didn't fail (e.g. because they couldn't be run
% for some reason). Again, empty is good. N.B. in practice,
% we don't use warnings very much.


%% initialize variables
% initialize the variables that are going to keep track of
% the status of things. ideally, they'll be pristine at the
% end of all our tests, indicating success
errs = {};
warns = {};

%% run the tests
% We're going to put all the individual tests in their own
% functions. Besides being neat, this serves a purpose,
% because it forces you to recreate all your variables from
% scratch each test. Otherwise, there's a possibility that
% your tests might be reusing an existing variable, and not
% testing what you think they're testing. Just make sure to
% remember to call all the test functions...
[errs warns] = check_for_toolbox(errs, warns);

[errs warns] = default_behavior(errs, warns);
[errs warns] = test_actselname(errs, warns);


%% output to screen?
% if you're running interactively, leave this in. take it
% out once you're ready for the test to be part of the
% RUN_TESTS suite
%
% it'll spit out a summary of any errors, just for this
% function
[errs warns] = alert_unit_errors(errs,warns);



function [errs warns] = check_for_toolbox(errs,warns)
% Check that we have everything we need to run the test.

% TODO: if there are cases where you're not able to run your
% tests, might as well just flag these as warnings
if ~exist('tutorial_easy')
  warns{end+1} = 'MVPA toolbox is not in the path - won''t be able to run remaining tests';
  
  % if that requirement was critical for your tests, you
  % might as well just exit now, and avoid the inevitable
  % error. that way, the rest of your unit tests can still
  % be run
  return
end


function [subj] = create_synthetic_data()

% If you need to create synthetic data that's going to get
% reused by lots of your tests, put the function(s) to do it
% here, and then just keep calling them in the individual
% tests.

% runs: 2 runs with 9 time points each
runs = repmat(1:2,9,1);
runs = runs(:)';

% regs: two regressors, 3 time points for each contained within each run +
%       3 time points of rest in each run.
regs = [0 0 0 1 1 1 0 0 0 0 0 0 1 1 1 0 0 0; 0 0 0 0 0 0 1 1 1 0 0 0 0 0 0 1 1 1];

% actsel: active time points (ie, not rest)
actsel = sum(regs); % NB equivilent to: subj = create_norest_sel(subj,'orig_regs');

% put everything in subj structure
subj = init_subj('scramb_regs_test','unit_test');
subj = init_object(subj,'regressors','orig_regs');
subj = set_mat(subj,'regressors','orig_regs',regs);

subj = init_object(subj,'selector','runs');
subj = set_mat(subj,'selector','runs',runs);

subj = init_object(subj,'selector','actsel');
subj = set_mat(subj,'selector','actsel',actsel);




function [errs warns] = default_behavior(errs,warns)
% Just making sure our synthetic data works with the default function
% behavior, scrambling does something, and scrambling occurs for "rest"
% time points.

try
    subj = create_synthetic_data;
    subj = scramble_regressors_custom(subj,'orig_regs','runs','default_scramb_regs');
catch
    errs{end+1} = 'Can''t run scramble_regressors on synthetic data with default settings.  Check synthetic data in unit test for scramble_regressors';
end

orig_regs = get_mat(subj,'regressors','orig_regs');
scramb_regs = get_mat(subj,'regressors','default_scramb_regs');
runs = get_mat(subj,'selector','runs');

% check the results
if issame(orig_regs,scramb_regs)
    % scrambling should change regressors
    errs{end+1} = 'It doesn''t appear that any scrambling of the regressors occurred for default behavior';
end
if issame(sum(scramb_regs),sum(runs))
    % then we haven't scrambled "rest" time points, but that should be the
    % default behavior without using an 'active_selname' argument
    errs{end+1} = 'Default scrambling ignored rest time points, but it shouldn''t';
end


function [errs warns] = test_actselname(errs,warns)
% Verify that ACTIVE_SELNAME argument works and allows us to limit scrambling
% to active time points.

subj = create_synthetic_data;
subj = scramble_regressors_custom(subj,'orig_regs','runs','actsel_scramb_regs','actives_selname','actsel');

orig_regs = get_mat(subj,'regressors','orig_regs');
scramb_regs = get_mat(subj,'regressors','actsel_scramb_regs');
actsel = get_mat(subj,'selector','actsel');

% check the results
if issame(orig_regs,scramb_regs)
    % scrambling should change regressors
    errs{end+1} = 'It doesn''t appear that any scrambling of the regressors occurred when using active_selname';
end
if ~issame(actsel,sum(scramb_regs))
  % scrambling should be limited to active time points
  errs{end+1} = 'scrambling occurred for non-active time points when using active_selname';
end




