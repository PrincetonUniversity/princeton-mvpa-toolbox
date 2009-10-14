function [errmsgs warnmsgs] = unit_zscore_runs()

% [ERRMSGS WARNMSGS] = UNIT_ZSCORE_RUNS()
% 
% This is a script that tests the test_zscore_runs function. It
% does negative and positive tests on the pattern, selectors and
% the actives selectors.
%
% ERRMSGS = cell array holding the error strings
% describing any tests that failed. If this is empty,
% that's a good thing
%
% WARNMSGS = cell array, like ERRMSGS, of tests that didn't pass
% and didn't fail (e.g. because they weren't run)


%initialising the *msgs cell arrays
errmsgs = {}; 
warnmsgs = {};


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% this is a negative test.
% this test should fail if the function works with no arguments.
try
  subj = zscore_runs();
  errmsgs{end+1} = 'No arguments test:failed';
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% checks if you have the stat toolbox 
if isempty(which('zscore'))
  warnmsgs{end+1} = 'No Stats toolbox zscore to compare it to';
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% this is a test for regular data and the zscore function 

[subj data] = create_fake_data();

% getting the desired and the zscore_runs output
desired = my_zscore(get_mat(subj,'selector','default_runs'),data);
subj = zscore_runs(subj,'fake_data','default_runs');

%comparing both the outputs.
if ~isequal(get_mat(subj,'pattern','fake_data_z'),desired) 
  errmsgs{end+1} = 'Regular data Test: Not the desired output'; 
end

clear desired;
clear subj;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% this is a test for regular data with the zscore_mvpa function  

[subj data] = create_fake_data();

% getting the desired and the zscore_runs output
desired = my_zscore(get_mat(subj,'selector','default_runs'),data);
subj= zscore_runs(subj,'fake_data','default_runs','use_mvpa_ver',1);

%comparing both the outputs
if ~isequal(get_mat(subj,'pattern','fake_data_z') , desired) 
  errmsgs{end+1} = 'Regular data with zscore_mvpa: Not the desired output'; 
end

clear desired;
clear subj;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% this is a negative test.
% this test should fail if the function works with  binary ruXX
[subj data] = create_fake_data();
binary_runs = [1 0 0 0 0 1 0 1 0 1 0 0 1 1 1 1 1 1 1 1 0 0 0 0 1];
subj = initset_object(subj,'selector','binary_runs',binary_runs);
try
  eval('[subj]= zscore_runs(subj,''fake_data'',''binary_runs'')');
  errmsgs{end+1} = 'Binary Test : failed';
end
clear subj;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% this is a negative test.
% this test should fail if the function works for runs with zeros in them

[subj data] = create_fake_data();
runs_with_zeros = [1 1 1 1 0 1 1 1 1 0 0 0 0 0 1 1 1 1 1 2 2 2 2 2 2];
subj = initset_object(subj,'selector','runs_with_zeros',runs_with_zeros);
try
  eval('[subj]= zscore_runs(subj,''fake_data'',''runs_with_zeros'')');
  errmsgs{end+1} = 'Runs_with_zeros Test : failed';
end
clear subj;

% xxx the next tests don't really relate to zscore_runs. the
% first part is really a set_mat test, and the second part
% fails because no object called decimal_runs exists, and
% has nothing to do with zscore_runs itself
%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % this is a test for runs with decimals in them
%
% [subj data] = create_fake_data();
% decimal_runs = [1.5 1.5 1.5 1.5 1.5 2.5 2.5 2.5 2.5 2.5 3.5 3.5 3.5 3.5 3.5 4.5 4.5 4.5 4.5 4.5 5.5 5.5 5.5 5.5 5.5 ];
% try
%   subj = initset_object(subj,'selector','decimal_runs',decimal_runs);
%   errmsgs{end+1} = 'Set Mat Test Failed';
% end
%
% try
%   eval('[subj]= zscore_runs(subj,''fake_data'',''decimal_runs'')');
%   errmsgs{end+1} = 'Runs_with_Decimal Test : failed';
% end
% 
% clear subj;
%
%
% xxx same goes for this test
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% this is a negative test.
% this test should fail if the function works for runs with decimals in them
%
% [subj data] = create_fake_data();
% some_decimals_runs = [1.55 1 1 1 1 2 2 2 2 2 3 3 3 3 3 4 4 4 4 4 5 5 5 5 5];
%
% try
%   subj = initset_object(subj,'selector','some_decimals_runs',some_decimals_runs);
%   errmsgs{end+1} = 'Set Mat Test Failed -1';
% end
%
% try
%   eval('[subj]= zscore_runs(subj,''fake_data'',''some_decimals_runs'')');
%   errmsgs{end+1} = 'Runs_with_some_decimals Test : failed';
% end
%
% clear subj;


% xxx same again
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% this is a negative test.
% this test should fail if the function works for runs with NaN or inf in them
%
% [subj data] = create_fake_data();
%
% NaN_runs = [1 1 1 1 1 2 NaN 2 2 2 3 3 3 3 3  4 4 4 4 4 5 5 5 5 5];
%
% try
%   subj = initset_object(subj,'selector','NaN_runs',NaN_runs);
%   errmsgs{end+1} = 'Set Mat Test Failed -2';
% end
%
% try
%   eval('[subj]= zscore_runs(subj,''fake_data'',''NaN_runs'')');
%   errmsgs{end+1} = 'Runs_with_NaN Test : failed';
% end

% clear subj;


%%%%%%%%%%%%%%%%%%%%%%%%%%%
% this test checks if the function works for different nos of TRs

[subj data] = create_fake_data();

% creating fake selectors
not_same_TRs_runs = [1 1 1 1 1 2 2 2 2 2 2 3 3 3 3 3 3 4 4 4 5 5 5 5 5];
subj = initset_object(subj,'selector','not_same_TRs_runs',not_same_TRs_runs);

subj= zscore_runs(subj,'fake_data','not_same_TRs_runs');
desired = my_zscore(get_mat(subj,'selector','not_same_TRs_runs'),data);

% comparing both the outputs.
if ~isequal(get_mat(subj,'pattern','fake_data_z'),desired) 
  errmsgs{end+1} = 'Regular data: Not the desired output'; 
end

clear desired;
clear subj;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% this test checks if the function works for missing runs

[subj data] = create_fake_data();

% creating fake selectors
missing_runs = [1 1 1 1 1 3 3 3 3 3 4 4 4 4 4 5 5 5 5 5 6 6 6 6 6];
subj = initset_object(subj,'selector','missing_runs',missing_runs);

[subj]= zscore_runs(subj,'fake_data','missing_runs');
[desired] = my_zscore(get_mat(subj,'selector','missing_runs'),data);

%comparing both the outputs.
if ~isequal(get_mat(subj,'pattern','fake_data_z'),desired) 
  errmsgs{end+1} = 'Regular data: Not the desired output'; 
end
clear desired;
clear subj;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% negative test
% this test should fail if you feed in jumbled runs by default

[subj data] = create_fake_data();

% creating fake selectors
jumbled_runs = [1 1 2 2 1 3 3 3 3 3 4 4 4 4 4 5 5 5 5 5 6 6 6 6 6];
subj = initset_object(subj,'selector','jumbled_runs',jumbled_runs);

try
  [subj]= zscore_runs(subj,'fake_data','jumbled_runs');
  errmsgs{end+1} = 'Runs with jumbled runs by default';
end
clear desired subj


%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% this test checks if the function works for jumbled runs if
% you set it to ignore them

[subj data] = create_fake_data();

% creating fake selectors
jumbled_runs = [1 1 2 2 1 3 3 3 3 3 4 4 4 4 4 5 5 5 5 5 6 6 6 6 6];
subj = initset_object(subj,'selector','jumbled_runs',jumbled_runs);

[subj]= zscore_runs(subj,'fake_data','jumbled_runs','ignore_jumbled_runs',true);
[desired] = my_zscore(get_mat(subj,'selector','jumbled_runs'),data);

%comparing both the outputs.
if ~isequal(get_mat(subj,'pattern','fake_data_z'),desired) 
  errmsgs{end+1} = 'Regular data: Not the desired output'; 
end
clear desired subj;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% this is a negative test.
% this test should fail if the function works with different TRs for runs and patterns

[subj data] = create_fake_data();

% creating fake selectors
diffTRs_runs = [1 1 1 1 1 2 2 2 2 2 3 3 3 3 3 4 4 4 4 4];
subj = initset_object(subj,'selector','diffTRs_runs',diffTRs_runs);

try
  [subj]= zscore_runs(subj,'fake_data','diffTRs_runs');
  errmsgs{end+1} = 'Different TRs Test :Failed'
end

clear desired;
clear subj;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% this test checks if the function works if we have only one run

[subj data] = create_fake_data();

% creating fake selectors
one_run = ones(1,25);

subj = initset_object(subj,'selector','one_run',one_run);

[subj]= zscore_runs(subj,'fake_data','one_run');
[desired] = my_zscore(get_mat(subj,'selector','one_run'),data);

%comparing both the outputs.
if ~isequal(get_mat(subj,'pattern','fake_data_z'),desired) 
  errmsgs{end+1} = 'One Run test: Not the desired output'; 
end

clear desired;
clear subj;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% this test checks if the function works if we have a negative
% no. in the runs

% GJD - commented this test out, because set_mat won't allow
% negative selectors now

% [subj data] = create_fake_data();
% neg_run = [1 1 1 1 1 1 1 1 1 -1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1];
% subj = initset_object(subj,'selector','neg_run',neg_run);

% try
%   [subj]= zscore_runs(subj,'fake_data','neg_run');
%   errmsgs{end+1} = 'Negative values in run Test :Failed';  
% end

% clear subj;


% we changed the actives_selname behavior, so that now it
% applies the parameters learned on the active timepoints to
% the whole run, so this test is no longer right. see the
% new test below

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % test the actives_selname optional argument

% [subj data] = create_fake_data();

% actives = ones(1,25);
% actives([10 20]) = 0;
% subj = initset_object(subj,'selector','actives',actives);
% subj = zscore_runs(subj,'fake_data','default_runs','actives_selname' ,'actives');

% runs_actives = get_mat(subj,'selector','default_runs');
% runs_actives(find(~actives)) = 0;
% desired = my_zscore(runs_actives,data);

% %comparing both the outputs.
% if ~isequal(get_mat(subj,'pattern','fake_data_z'),desired) 
%   errmsgs{end+1} = ['Using the optional actives_selname argument doesn''t work']; 
% end

% clear subj;
% clear desired;
% clear runs_actives,
% clear actives;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% test the actives_selname optional argument when it is all 1's

[subj data] = create_fake_data();

actives = ones(1,25);
runs_actives = get_mat(subj,'selector','default_runs');
runs_actives(find(~actives)) = 0;
desired = my_zscore(runs_actives,data);

subj = initset_object(subj,'selector','actives',actives);
[subj] = zscore_runs(subj,'fake_data','default_runs','actives_selname','actives');

%comparing both the outputs.
if ~isequal(get_mat(subj,'pattern','fake_data_z'),desired) 
  errmsgs{end+1} = ['Using the optional actives_selname argument doesn''t work if all ones']; 
end

clear subj;
clear desired;
clear runs_actives,
clear actives;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% test the actives_selname optional argument when it is all 0's

[subj data] = create_fake_data();

actives = zeros(1,25);
runs_actives = get_mat(subj,'selector','default_runs');
runs_actives(find(~actives)) = 0;
desired = my_zscore(runs_actives,data);

subj = initset_object(subj,'selector','actives',actives);
[subj] = zscore_runs(subj,'fake_data','default_runs','actives_selname','actives');

%comparing both the outputs.
if ~isequal(get_mat(subj,'pattern','fake_data_z'),desired) 
  errmsgs{end+1} = ['Using the optional actives_selname argument doesn''t work if all zeros']; 
end

clear subj;
clear desired;
clear runs_actives,
clear actives;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% this is a negative test.
% this test should fail if the function works if the
% actives_selname has any negative values

% GJD - commented this test out, because set_mat won't allow
% negative selectors now

% [subj data] = create_fake_data();

% actives = [1 1 1 1 1 1 1 1 1 -1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1];
% [subj] = initset_object(subj,'selector','actives',actives);

% try
%   [subj] = zscore_runs(subj,'fake_data','default_runs', ...
% 		       'actives_selname','actives');  
%   errmsgs{end+1} = 'The negative actives test: Failed';
% end

% clear subj;
% clear actives;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% ADD OVERWRITE TEST %%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Test for zscore by active_select only

subj = init_subj('UNIT_ZSCORE_RUNS','fake_subj');
subj = initset_object(subj,'selector','default_runs', ...
                      ones(1,5));
subj = initset_object(subj,'mask','wholevol',ones(1,1,2));

% we're going to take some simple data where we've
% precalculated the right answer, and check against that
pat = [10 20 30 40 50 ; 100 200 300 400 500];
subj = initset_object(subj,'pattern','fake_data',pat, ...
                      'masked_by','wholevol');
actives_a = [1 1 1 0 0];
actives_b = [0 0 1 1 1];
subj = initset_object(subj,'selector','actives_a',actives_a);
subj = initset_object(subj,'selector','actives_b',actives_b);

% for future reference, this is how we calculated it by hand
% mean_a = mean(pat(:,actives_a),2);
% mean_b = mean(pat(:,actives_b),2);
% std_a = std(pat(:,actives_a),[],2);
% std_b = std(pat(:,actives_b),[],2);
% pat_a = (pat-mean_a(:,ones(1,size(pat,2))))./std_a(:,ones(1,size(pat,2)));
% pat_b = (pat-mean_b(:,ones(1,size(pat,2))))./std_b(:,ones(1,size(pat,2)));

% here's one i made earlier
pat_a = [-1     0     1     2     3;
         -1     0     1     2     3];

pat_b = [-3    -2    -1     0     1; 
         -3    -2    -1     0     1];

subj = zscore_runs(subj,'fake_data','default_runs', ...
                   'actives_selname','actives_a', ...
                   'new_patname','fake_data_a_z');

subj = zscore_runs(subj,'fake_data','default_runs', ...
                   'actives_selname','actives_b', ...
                   'new_patname','fake_data_b_z');

if ~isequal(pat_a, get_mat(subj,'pattern','fake_data_a_z'))
  errmsgs{end+1} = 'actives_a yielded the wrong result';
end
if ~isequal(pat_b, get_mat(subj,'pattern','fake_data_b_z'))
  errmsgs{end+1} = 'actives_b yielded the wrong result';
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% END OF TESTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [subj data] = create_fake_data();

data = rand(10,25);
simplemask  = ones(1,1,10);
subj = init_subj('test_zscore_runs','testsubj');
subj = initset_object(subj,'mask','simplemask',simplemask);
subj = initset_object(subj,'pattern','fake_data',data, ...
                      'masked_by','simplemask');
% this is the default selector, you can change the selector
% with the create_fake_sel function 
default_runs = [1 1 1 1 1 2 2 2 2 2 3 3 3 3 3 4 4 4 4 4 5 5 5 5 5];
subj = initset_object(subj,'selector','default_runs',default_runs);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [desired] = my_zscore(sel,data);

% this carries out the regular zscore function so we can compare
% its output against the zscore_runs. 

desired = data;
for i=1:max(sel)
  foundruns = find(sel==i);
  desired(:,foundruns)= zscore(data(:,foundruns)')';   
end

