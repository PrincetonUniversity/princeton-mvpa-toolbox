function [errmsgs warnmsgs] = unit_set_mat()

% USAGE :[ERRMSGS WARNMSGS] = TEST_SET_MAT()
% 
% This is a script that tests the test_sets_mats function. It
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
  subj = set_mat();
  errmsgs{end+1} = 'No arguments test:failed'
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% this is a basic test for the function
% we send in the input arguments and test if they are stored in as
% they are supposed to.


[subj data] = create_fake_pats();

% subj = init_subj('test_zscore_runs','testsubj');
% data = rand(10,25);
% [subj] = init_object(subj,'pattern','data');
% [subj] = set_mat(subj,'pattern','data' ,data);

if ~isequal(subj.patterns{1}.mat,data)
   errmsgs{end+1} = 'Pattern Set Test : Failed';
end

if ~strcmp(subj.patterns{1}.name,'data')
   errmsgs{end+1} = 'Pattern Name Set Test : Failed';
end

if ~isequal(subj.patterns{1}.matsize,size(data))
   errmsgs{end+1} = 'Pattern Size Set Test : Failed';
end

clear subj;

% init an object, then set a mat into it
% check that get gives you it back as before

%%%% we can add more if necessary %%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% this is a check for using the same object, set a new mat into it (i.e. modify the existing one)
% check that get gives you it back before (using regressors)


[subj data] = create_fake_regs();
regs = [1 1 1 1 1 0 0 1 1 1 1];
[subj] = set_mat(subj,'regressors','regs' ,regs);


if ~isequal(get_mat(subj, 'regressors', 'regs'), regs)
  errmsgs{end+1} = 'Modify Regressors Set Test : Failed'
end  

if ~strcmp(subj.regressors{1}.name,'regs')
   errmsgs{end+1} = 'Regressors Name Set Test : Failed';
end

% check that the '.matsize' field gets updated appropriately
if ~isequal(subj.regressors{1}.matsize,size(regs))
   errmsgs{end+1} = 'Regressors Size Set Test : Failed';
end

clear subj; 
warnmsgs{end+1} = lastwarn;
 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% this is a check for using the same object, set a new mat into it (i.e. modify the existing one)
% check that get gives you it back before (using selectors)


%????????????????? we save send the objtype as selector/pattern and then it
% saves as selectors/patterns... what is this????????? 
% very annoying!!!!!!


[subj data] = create_fake_sel();
runs = [1 1 1 1 1 2 2 2 2 2];
[subj] = set_mat(subj,'selector','runs' ,runs);


if ~isequal(get_mat(subj, 'selector', 'runs'), runs)
  errmsgs{end+1} = 'Modify Selector Set Test : Failed'
end  

if ~strcmp(subj.selectors{1}.name,'runs')
   errmsgs{end+1} = 'Selector Name Set Test:Failed';
end

% check that the '.matsize' field gets updated appropriately
if ~isequal(subj.selectors{1}.matsize,size(runs))
   errmsgs{end+1} = 'Selector Size Set Test : Failed';
end

clear subj; 
warnmsgs{end+1} = lastwarn;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% try moving the object to the hard disk
% set the mat, then get the mat
% load the object back from the hard disk
% set the mat, then get the mat

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% negative tests for all the sanity checks (including the ones
% specific to each object type)

% three dimensional data
data = rand(3,3,10);
try
  [subj data] = create_fake_pats(data);
    errmsgs{end+1} = 'Data dimenstions Test -1: Failed '
end

clear subj;clear data;

% three dimensional data
data = rand(3, [], 10);
try
  [subj data] = create_fake_pats(data);
  errmsgs{end+1} = 'Data dimenstions Test -2 : Failed'
end
clear subj;

% string data
data = 'Hey';
try
  [subj data] = create_fake_pats(data);
  errmsgs{end+1} = 'Data Type Test -1 : Failed'
end

clear subj;


% We decided to remove this negative test, because if the user
% wants to use set_mat to put an empty matrix into an object, we're
% going to let them. We may want to reconsider this, and not let
% users set empty matrices in future though (this would require
% modifying remove_mat somehow, or having a flag that says 'allow
% empty matrices').
%
% data = rand(0);
% try
%   [subj data] = create_fake_pats(data);
%   errmsgs{end+1} = 'Data dimenstions Test -3 : Failed'
% end
% clear subj;


% -ve integers in selectors 
sel = [1 1 1 1 1 -2 -2 2 2 2 3 -3 3 3 ];
try
  [subj data] = create_fake_sel(sel);
    errmsgs{end+1} = 'Negartive Selector Test: Failed '
end
clear subj;

% string selector
sel = 'Hey';
try
  [subj data] = create_fake_sel(sel);
    errmsgs{end+1} = 'Data Type Test -2: Failed '
end
clear subj;


% here there is no need to check if the selectors have zeros in it
% or not as this test does not know about the actives..
%sel = [1 1 1 1 1 2 2 2 0 2 3 3 3 3 ];
% try
%   [subj data] = create_fake_sel(sel);
%     errmsgs{end+1} = 'Negartive Selector Test: Failed '
% end


% do we care if two conditions are on at the same time???
% in the Free recall experiment we had situations where that
% happened. Do the scripts take of that ??? or do we not care?

% regs =[1 0 0 0; 0 1 0 0; 1 0 1 0; 0 0 0 1];
% try
%   [subj data] = create_fake_regs(regs);
%   errmsgs{end+1} = ' Regressor Test: Failed';
% end

% string in regs
regs ='Hey';
try
  [subj data] = create_fake_regs(regs);
  errmsgs{end+1} = ' Data Type Test -3: Failed';
end
clear subj;

regs = [1 1 1 1 't' 1 1 1 ];
try
  [subj data] = create_fake_regs(regs);
  errmsgs{end+1} = ' Data Type Test -4: Failed';
end
clear subj;

% can a mask have anything other than binary?
% we have to add a sanity check for that????

% string mask
mask ='Hey';
try
  [subj mask] = create_fake_mask(mask);
  errmsgs{end+1} = ' Data Type Test -5: Failed';
end
clear subj;

% the following tests can be deleted if we have masks on in binary form????

% 1 - dim mask
mask = rand(30);
try
  [subj mask] = create_fake_mask(mask);
  errmsgs{end+1} = ' Mask Set Test : Failed';
end
clear subj;

% 4 dims mask
mask = rand(30,30,30,30);
try
  [subj mask] = create_fake_mask(mask);
  errmsgs{end+1} = ' Mask Set Test : Failed';
end
clear subj;

% 1- dim missing mask
mask = rand(3, 0, 3);
try
  [subj mask] = create_fake_mask(mask);
  errmsgs{end+1} = ' Mask Set Test : Failed';
end
clear subj;
 
% 1- dim missing mask
mask = rand(3, 0, 3);
try
  [subj mask] = create_fake_mask(mask);
  errmsgs{end+1} = ' Mask Set Test : Failed';
end
clear subj;
 
%%%%%% creates a temp subj %%%%%%%%%%%%%%%%%
function [subj data] = create_fake_pats(varargin);

if nargin<1  
  data = rand(10,25);
else  
  data= varargin{1};
  
end

subj = init_subj('test_zscore_runs','testsubj');  
[subj] = init_object(subj,'pattern','data');
[subj] = set_mat(subj,'pattern','data' ,data);

%%%%%% creates a temp subj %%%%%%%%%%%%%%%%%
function [subj runs] = create_fake_sel(varargin);

if nargin<1  
  runs = [1 1 1 1 1 2 2 2 2 2 3 3 3 3 3 4 4 4 4 4 5 5 5 5 5];
else  
  runs= varargin{1};
end

subj = init_subj('test_zscore_runs','testsubj');
[subj] = init_object(subj,'selector','runs');
[subj] = set_mat(subj,'selector','runs' ,runs);

%%%%%% creates a temp subj %%%%%%%%%%%%%%%%%
function [subj regs] = create_fake_regs(varargin);

if nargin<1  
  regs = [1 1 1 1 1 0 0 0 1 1 1 0 1 1 0 1 0 1 0 1 0 1 0 1 1 ];
else   
  regs = varargin{1};
end

subj = init_subj('test_zscore_runs','testsubj');  
[subj] = init_object(subj,'regressors','regs');
[subj] = set_mat(subj,'regressors','regs' ,regs);  
  
%%%%%% creates a temp subj %%%%%%%%%%%%%%%%%
function [subj mask] = create_fake_mask(varargin);

if nargin<1  
  mask = rand(30, 30, 30);
else   
  mask = varargin{1};
end

subj = init_subj('test_zscore_runs','testsubj');  
subj = init_object(subj,'mask','mask');
subj = set_mat(subj,'mask','mask' ,mask);  
