function [errs warns] = unit_template()

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
[errs warns] = test1(errs, warns);
[errs warns] = test0(errs, warns);
[errs warns] = test2(errs, warns);

% if you're running interactively, leave this in. take it
% out once you're ready for the test to be part of the
% RUN_TESTS suite
%
% it'll spit out a summary of any errors, just for this
% function
[errs warns] = alert_unit_errors(errs,warns);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [errs warns] = test0(errs,warns)

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


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [errs warns] = test1(errs,warns)

% Negative unit tests (circumstances under which we want the
% program to fail) - akin to assertRaises in PyUnit

vec = create_some_synthetic_data();

try
  % Do something that should cause an error and
  % halt. If the program raises an error, it'll jump out of
  % the TRY block before adding to the ERRS cell
  % array. If the program completes without raising an
  % error, then that's bad, and we'll add it to the ERRS
  % cell array.
  %
  % TODO: add assertRaises-style tests in TRY blocks like
  % this
  vec(4)
  
  errs{end+1} = 'That was supposed to raise an ''index out of bounds'' error';
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [errs warns] = test2(errs,warns)

% Test whether the output of the function is what it's
% supposed to be - akin to assertEqual in PyUnit

% TODO: add assertEquals-style tests just with IF-statements
% like this
if 2+2~=4
  errs{end+1} = 'Oh crap. The world is going to end';
end
if 2+2~=5
  % but freedom is supposed to be the freedom to think this...
  errs{end+1} = 'You need to practice your arithmetic';
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [vec] = create_some_synthetic_data()

% If you need to create synthetic data that's going to get
% reused by lots of your tests, put the function(s) to do it
% here, and then just keep calling them in the individual
% tests.

% some 21st century synthetic data
vec = [1 2 3];

