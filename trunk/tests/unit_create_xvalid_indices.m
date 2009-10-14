function [errmsgs warnmsgs] = unit_create_xvalid_indices()

% [ERRMSGS WARNMSGS] = UNIT_CREATE_XVALID_INDICES()
% 
% This is a script that tests CREATE_XVALID_INDICES.M. It
% does negative and positive tests on the selectors and
% the actives selectors.
%
% ERRMSGS = cell array holding the error strings
% describing any tests that failed. If this is empty,
% that's a good thing
%
% WARNMSGS = cell array, like ERRMSGS, of tests that didn't pass
% and didn't fail (e.g. because they weren't run)


errmsgs = {}; 
warnmsgs = {};

[errmsgs warnmsgs] = neg_zero_args(errmsgs,warnmsgs);
[errmsgs warnmsgs] = pos_runs_std(errmsgs,warnmsgs);
[errmsgs warnmsgs] = pos_runs_std_actives(errmsgs,warnmsgs);
[errmsgs warnmsgs] = pos_missing_runs(errmsgs,warnmsgs);
[errmsgs warnmsgs] = neg_one_run_only(errmsgs,warnmsgs);
[errmsgs warnmsgs] = neg_nonbinary_actives(errmsgs,warnmsgs);
[errmsgs warnmsgs] = neg_zeros_in_runs(errmsgs,warnmsgs);
[errmsgs warnmsgs] = neg_diff_lengths(errmsgs,warnmsgs);
[errmsgs warnmsgs] = neg_jumbled_runs(errmsgs,warnmsgs);
[errmsgs warnmsgs] = pos_jumbled_runs(errmsgs,warnmsgs);
[errmsgs warnmsgs] = pos_new_selstem(errmsgs,warnmsgs);
[errmsgs warnmsgs] = neg_overwrite(errmsgs,warnmsgs);




% for when you're testing things interactively
[errmsgs warnmsgs] = alert_unit_errors(errmsgs,warnmsgs);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [errmsgs warnmsgs] = neg_zero_args(errmsgs,warnmsgs)

try
  subj =  create_xvalid_indices();
  errmsgs{end+1} = 'Shouldn''t run with zero arguments'
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [errmsgs warnmsgs] = pos_runs_std(errmsgs,warnmsgs)

% this is a test to check if the script creates the x valid
% indices the correct way

[subj data] = create_fake_data();
subj = create_xvalid_indices(subj,'runs_std');

% desired is an object that comtains all the 5 combinations of the
% test/train TRs. 
desired{1} = [2 2 2 2 2 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1];
desired{2} = [1 1 1 1 1 2 2 2 2 2 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1];
desired{3} = [1 1 1 1 1 1 1 1 1 1 2 2 2 2 2 1 1 1 1 1 1 1 1 1 1];
desired{4} = [1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 2 2 2 2 2 1 1 1 1 1];
desired{5} = [1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 2 2 2 2 2];

new_errmsg = 'Pos - standard runs';
[errmsgs warnmsgs] = check_against_desired(errmsgs,warnmsgs, ...
                                           subj,'runs_std_xval',desired, ...
                                           new_errmsg);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [errmsgs warnmsgs] = pos_runs_std_actives(errmsgs,warnmsgs)

[subj data] = create_fake_data();

actives = [1 1 1 1 0 0 1 1 1 0 0 0 0 0 0 1 1 1 0 0 1 0 0 1 0];
[subj] = initset_object(subj,'selector','actives',actives);
[subj] = create_xvalid_indices(subj,'runs_std', 'actives_selname','actives');

% desired is an object that comtains all the 5 combinations of the
% test/train TRs. 
desired{1} = [2 2 2 2 0 0 1 1 1 0 0 0 0 0 0 1 1 1 0 0 1 0 0 1 0];
desired{2} = [1 1 1 1 0 0 2 2 2 0 0 0 0 0 0 1 1 1 0 0 1 0 0 1 0];
desired{3} = [1 1 1 1 0 0 1 1 1 0 0 0 0 0 0 1 1 1 0 0 1 0 0 1 0];
desired{4} = [1 1 1 1 0 0 1 1 1 0 0 0 0 0 0 2 2 2 0 0 1 0 0 1 0];
desired{5} = [1 1 1 1 0 0 1 1 1 0 0 0 0 0 0 1 1 1 0 0 2 0 0 2 0];

new_errmsg = 'Pos - stndard runs with actives';
[errmsgs warnmsgs] = check_against_desired(errmsgs,warnmsgs, ...
                                           subj,'runs_std_xval',desired, ...
                                           new_errmsg);




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [errmsgs warnmsgs] = pos_missing_runs(errmsgs,warnmsgs);

% check that it deals with missing runs correctly

[subj data] = create_fake_data();

% creating fake selectors
missing_runs = [1 1 1 1 1 3 3 3 3 3 4 4 4 4 4 5 5 5 5 5 6 6 6 6 6];
[subj] = initset_object(subj,'selector','missing_runs',missing_runs);

subj = create_xvalid_indices(subj,'missing_runs');

% the DESIRED cell array contains a vector for each of the selector iterations
%
% N.B. the number of withheld runs = max(runs). So if
% there's a run missing, it still gets its own iteration,
% but with no testing timepoints.
desired{1} = [2 2 2 2 2 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1];
% this is the missing run that has no testing timepoints
desired{2} = [1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1];
desired{3} = [1 1 1 1 1 2 2 2 2 2 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1];
desired{4} = [1 1 1 1 1 1 1 1 1 1 2 2 2 2 2 1 1 1 1 1 1 1 1 1 1];
desired{5} = [1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 2 2 2 2 2 1 1 1 1 1];
desired{6} = [1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 2 2 2 2 2];

new_errmsg = 'Pos - missing runs';
[errmsgs warnmsgs] = check_against_desired(errmsgs,warnmsgs, ...
                                           subj,'missing_runs_xval',desired, ...
                                           new_errmsg);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [errmsgs warnmsgs] = neg_one_run_only(errmsgs,warnmsgs);

% % this is a negative test. this test should fail if the function
% % works with only one run

% [subj data] = create_fake_data();

% % creating fake selectors
% one_run = ones(1,25);
% [subj] = initset_object(subj,'selector','one_run',one_run);

% try
%   [subj] = create_xvalid_indices(subj,'one_runs');
%   errmsgs{end+1} = 'One Run test: failed';
% end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [errmsgs warnmsgs] = neg_nonbinary_actives(errmsgs,warnmsgs);

% this is a negative test. it should fail if the functions works when
% we pass anything other than binaries in the actives

[subj data] = create_fake_data();

actives = [1 1 1 1 2 2 2 1 1 0 0 0 0 0 0 1 1 1 0 0 1 0 0 1 0];
[subj] = initset_object(subj,'selector','actives',actives);

try
  [subj] = create_xvalid_indices(subj,'runs_std', 'actives_selname','actives');
  errmsgs{end+1} = 'Should only work for binary actives';
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [errmsgs warnmsgs] = neg_zeros_in_runs(errmsgs,warnmsgs);

% this is a negative test. it should fail if the function works when
% the runs have zeros in them.

[subj data] = create_fake_data();
runs_with_zeros = [0 0 0 0 0 1 1 1 1 1 2 2 2 2 2 3 3 3 3 3 4 4 4 4 4];
[subj] = initset_object(subj,'selector','runs_with_zeros',runs_with_zeros);

try
  [subj] = create_xvalid_indices(subj,'runs_with_zeros');
  errmsgs{end+1} = 'Runs_with_zeros Test: Failed'  
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [errmsgs warnmsgs] = neg_diff_lengths(errmsgs,warnmsgs);

% this is a negative test. it should fail if the function works when
% the lengths of runs and actives are not same.

[subj data] = create_fake_data();
actives_withlessTRs = [ 1 1 0 1 1 0 1 1 1 1 1 0 0 0 0 ];

[subj] = initset_object(subj,'selector','actives_withlessTRs',actives_withlessTRs);

try
  [subj] = create_xvalid_indices(subj,'runs_std','actives_selname','actives_withlessTRs');
  errmsgs{end+1} = 'Different runs and actives TRs Test: Failed'  
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [errmsgs warnmsgs] = neg_jumbled_runs(errmsgs,warnmsgs);

% this is a negative test. it should fail if the function
% works if we pass jumbled runs without an argument saying
% that jumbled runs are ok

[subj data] = create_fake_data();
jumbled_runs = [ 2 1 2 2 2 1 1 1 1 1 3 2 3 3 3 5 5 ...
    5 5 5 4 4 5 4 4];
[subj] = initset_object(subj,'selector','jumbled_runs',jumbled_runs);

try
  [subj] = create_xvalid_indices(subj,'jumbled_runs');
  errmsgs{end+1} = 'Jumbled_runs Test: Failed'  
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [errmsgs warnmsgs] = pos_jumbled_runs(errmsgs,warnmsgs);

% if the user specifically allows jumbled runs, then the
% function should work

[subj data] = create_fake_data();
jumbled_runs = [2 1 2 2 2 1 1 1 1 1 3 2 3 3 3 5 5 5 5 5 4 4 5 4 4];
[subj] = initset_object(subj,'selector','jumbled_runs',jumbled_runs);

[subj] = create_xvalid_indices(subj,'jumbled_runs','ignore_jumbled_runs',true);

% desired is an object that comtains all the 5 combinations of the
% test/train TRs. 
desired{1} = [1 2 1 1 1 2 2 2 2 2 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1];
desired{2} = [2 1 2 2 2 1 1 1 1 1 1 2 1 1 1 1 1 1 1 1 1 1 1 1 1];
desired{3} = [1 1 1 1 1 1 1 1 1 1 2 1 2 2 2 1 1 1 1 1 1 1 1 1 1];
desired{4} = [1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 2 2 1 2 2];
desired{5} = [1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 2 2 2 2 2 1 1 2 1 1];

new_errmsg = 'Pos - jumbled runs';
[errmsgs warnmsgs] = check_against_desired(errmsgs,warnmsgs, ...
                                           subj,'jumbled_runs_xval',desired, ...
                                           new_errmsg);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [errmsgs warnmsgs] = pos_new_selstem(errmsgs,warnmsgs);

% this is a check for new_selstem. 
% it checks if it assigns the new names to the selectors.

[subj data] = create_fake_data();
[subj] = create_xvalid_indices(subj,'runs_std','new_selstem','check_name');

for i=1:5
  desired_name = strcat('check_name_',num2str(i)) ; 
  if ~strcmp(subj.selectors{i+1}.name, desired_name)
    errmsgs{end+1} = 'The New Selector name Test : Failed';
  end
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [errmsgs warnmsgs] = neg_overwrite(errmsgs,warnmsgs);

% this is a negative test. it should fail if the function works if
% we try to over write things

[subj data] = create_fake_data();
[subj] = create_xvalid_indices(subj,'runs_std');

actives = [1 1 1 1 1 0 0 1 1 0 1 1 1 1 1 1 0 0 0 0 1 1 1 1 1];
[subj] = initset_object(subj,'selector','actives',actives);

try  
 [subj] = create_xvalid_indices(subj,'runs_std', 'new_selstem','runs_std_xval','actives_selname','actives');
  errmsgs{end+1} = 'Overwrite Test: Failed' ; 
end

warnmsgs{end+1} = lastwarn;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [subj data] = create_fake_data();

data =  rand(10,25);
simplemask = ones(1,1,10);

subj = init_subj('unit_create_xvalid_indices','testsubj');

% 5 standard runs, each with the same number of timepoints
runs_std = [1 1 1 1 1 2 2 2 2 2 3 3 3 3 3 4 4 4 4 4 5 5 5 5 5];
subj = initset_object(subj,'selector','runs_std',runs_std);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [errmsgs warnmsgs] = ...
    check_against_desired(errmsgs,warnmsgs,subj,sel_groupname,desired,new_errmsg)

% Runs through all the members of selector group
% SELNAME_PREFIX and checks them against the matrices in the
% DESIRED cell array. Get used by most of the positive tests.


members = find_group(subj,'selector',sel_groupname);
nMembers = length(members);

if nMembers ~= length(desired)
  errmsgs{end+1} = 'Wrong number of selectors';
  keyboard
end

for m=1:nMembers
  cur_selname = sprintf('%s_%i',sel_groupname,m);

  if ~isequal(get_mat(subj, 'selector', cur_selname), desired{m})
    errmsgs{end+1} = new_errmsg;
    keyboard
  end  

end % m


