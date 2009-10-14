function [errmsgs warnmsgs] = unit_hd_scripts()


% USAGE :[ERRMSGS WARNMSGS] = UNIT_HD_SCRIPTS()
% 
% This is a script that tests the move_pattern_to_hd and the
% load_pattern_from_hd functions.
%
% ERRMSGS = cell array holding the error strings
% describing any tests that failed. If this is empty,
% that's a good thing
%
% WARNMSGS = cell array, like ERRMSGS, of tests that didn't pass
% and didn't fail (e.g. because they weren't run)
%
% xxx - it would be nice if this function were to clean up
% the directories it creates after itself...


%initialising the *msgs cell arrays
errmsgs = {}; 
warnmsgs = {};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% this is a negative test.
% this test should fail if the function works with no arguments.
try
  subj =  move_pattern_to_hd();
  errmsgs{end+1} = 'No arguments test:failed -1'
end

try
  subj =  load_pattern_to_hd();
  errmsgs{end+1} = 'No arguments test:failed -2'
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% these tests are for the move/load data into the Hard drive
% these test work only on patterns...so do we want it to also work
% for other stuff?

% first i create my subj structure
[subj data] = create_fake_pats();

% now i will move it the new_data to the hard drive
subj = move_pattern_to_hd(subj,'data');

% check if is really moved
if ~isempty(subj.patterns{1}.mat)
  errmsgms{end+1} = 'Move to HD Test-1 : Failed';
end  

if ~exist_objfield(subj,'pattern','data','movehd')
  errmsgs{end+1} = 'Move data to HD -2 : Test Failed '; 

else   
  filename = subj.patterns{1}.movehd.pathfilename;
  
  
  load(filename);   
  if ~isequal(subj.patterns{1}.matsize,size(mat))		  
    errmsgs{end+1} = 'Pattern Size Test on HD-1 = Failed';    
  end  
end

% now I load the data using the load pattern from hard drive script
[subj] =load_pattern_from_hd(subj,'data');

% check if it loads in correctly
if isempty(subj.patterns{1}.mat)
  errmsgs{end+1} = 'Load to HD Test-1 : Failed';
end  

if exist_objfield(subj,'pattern','data','movehd')
  errmsgs{end+1} = 'Load data to HD -2 : Test Failed '; 
  
else  
  if ~isequal(subj.patterns{1}.matsize,size(mat))		  
    errmsgs{end+1} = 'Pattern Size Test on HD-2 = Failed';    
  end  
end

clear subj;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  now  I am just testing other things that the function are
%  supposed to do

% first i create my subj structure
[subj data] = create_fake_pats();

subj = move_pattern_to_hd(subj,'data');
filename = subj.patterns{1}.movehd.pathfilename;
% check if the leave on HD argument works
[subj] = load_pattern_from_hd(subj, 'data', 'leave_on_hd',1);
filename = strcat(filename,'.mat');

% check if file exists
if ~exist(filename)  
  errmsgs{end+1} = 'File Leave on HD  = Failed'; 
end


% let say I move a pattern to HD
% then i change the data using set_mat to a new pattern. 
subj = move_pattern_to_hd(subj,'data');
data = rand(100,25);
[subj] = set_mat(subj,'pattern','data' ,data);


% this can also be like a get_mat test
temp =  get_mat(subj,'pattern','data');
if ~isequal(temp, data)
  errmsgs{end+1} = 'Get Test from HD - Failed';
end

[subj] = load_pattern_from_hd(subj, 'data','leave_on_hd',1); 

if isempty(subj.patterns{1}.mat)
  errmsgs{end+1} = 'Load to HD Test-3 : Failed';
end  

if exist_objfield(subj,'pattern','data','movehd')
  errmsgs{end+1} = 'Load data to HD -4 : Test Failed '; 
  
else
  load(filename);  
  if ~isequal(subj.patterns{1}.matsize,size(mat))		  
    errmsgs{end+1} = 'Pattern Size Test on HD -3= Failed';    
  end  
end

clear subj;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% check for the sub_dir argument 
mydir_data = rand(25,25);
[subj data] = create_fake_pats(mydir_data,'mydir_data');
subj = move_pattern_to_hd(subj,'mydir_data','subdir','unit_hd_scripts_temp');


if ~isempty(subj.patterns{1}.mat)
  errmsgms{end+1} = 'Move to my dicrectory Test-1 : Failed';
end  

if ~exist_objfield(subj,'pattern','mydir_data','movehd')
  errmsgs{end+1} = 'Move data to my directory -2 : Test Failed '; 

else 
    
  filename = subj.patterns{1}.movehd.pathfilename;
  load(filename);
  
  if ~isequal(subj.patterns{1}.matsize,size(mat))		  
    errmsgs{end+1} = 'Pattern Size Test on HD -4= Failed';    
  end  
end

filename = strcat(filename,'.mat');
if ~exist(filename)  
    errmsgs{end+1} = 'File Leave on HD  = Failed'; 
 end

  [subj] = load_pattern_from_hd(subj, 'mydir_data'); 

 if isempty(subj.patterns{1}.mat)
   errmsgs{end+1} = 'Load to HD Test-5 : Failed';
 end  

 if exist_objfield(subj,'pattern','mydir_data','movehd')
   errmsgs{end+1} = 'Load data to HD - 5 : Test Failed ';   
 else    
   if ~isequal(subj.patterns{1}.matsize,size(mat))		  
     errmsgs{end+1} = 'Pattern Size Test on HD -5= Failed';    
   end  
 end

if exist(filename)  
  errmsgs{end+1} = 'File Still on HD = Failed'; 
end

clear subj;
 

% clean up after ourselves
rmdir('unit_hd_scripts_temp')


%%%%%%%%%%
% END of TEST
%%%%%% create the subj structure  %%%%%%%%%%%%%%%%%
function [subj data] = create_fake_pats(varargin);

if nargin<1  
  data = rand(10,25);
  name_data= 'data';
else  
  data = varargin{1};
  name_data = varargin{2};    
end

subj = init_subj('test_zscore_runs','testsubj');  
[subj] = init_object(subj,'pattern',name_data);
[subj] = set_mat(subj,'pattern',name_data ,data);


