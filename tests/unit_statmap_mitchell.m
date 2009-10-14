function [errmsgs warnmsgs] = unit_statmap_mitchell()

% USAGE :[ERRMSGS WARNMSGS] = TEST_STATMAP_MITCHELL()
% 
% This is a script that tests the mitchell voxel selection method.
%
% ERRMSGS = cell array holding the error strings
% describing any tests that failed. If this is empty,
% that's a good thing
%
% WARNMSGS = cell array, like ERRMSGS, of tests that didn't pass
% and didn't fail (e.g. because they weren't run)
%

%initialising the *msgs cell arrays
errmsgs = {}; 
warnmsgs = {};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% creating fake data
% this data will be a like a basic test for all the voxel seletion
% functions 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TEST 1
% each voxel in typically going be active only for one condition so
% we will have only 3 conditions and 3 voxels.

regs = [1 1 1 1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0; 0 0 0 0 0 1 1 1 1 ...
	1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 ; 0 0 0 0 0 0 0 0 0 0 1 1 1 1 1 0 0 0 ...
	0 0 0 0 0 0 0;0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 ...
       0 0];

sel = [1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 3 3 3 3 3 3 3 3 3 3 ];

% creating fake data
fake_data = repmat(regs(1,:),10,1);
fake_data = [fake_data; repmat(regs(2,:),10,1)];
fake_data = [fake_data ;repmat(regs(3,:),10,1)];
cnt=10;

for  i=1:30
  fake_data(i,:) = fake_data(i,:)* cnt;
  cnt=cnt-1;    
  if cnt==0;cnt = 10; end  
end

% plot the data
% imagesc(fake_data);

warning off;
desired = [1 4 7 10 13 16 19 22 25 28 2 5 8 11 14 17 20 23 26 29 3 6 9 12 15 ...
	   18 21 24 27 30];

subj  = makesubj(fake_data,regs,sel);

% calling the statmap function
extra_arg='';
[subj] = statmap_mitchell(subj,'testdata','testregs','testsel','test_map',extra_arg);

% checking...
if ~isequal(desired, subj.patterns{2}.mat )
  error('Perfect Data Ranking test :Failed');
end

clear subj;

%%%%%%%% make a subj structure %%%%%%%%%%%%%%%%%%%%
function subj  = makesubj(data, regs,sel)

subj = init_subj('test_voxel_selection','testsubj');  
subj = init_object(subj,'pattern','testdata');
subj = set_mat(subj,'pattern','testdata' ,data);  

subj = init_object(subj,'regressors','testregs');
subj = set_mat(subj,'regressors','testregs' ,regs);  

subj = init_object(subj,'selector','testsel');
subj = set_mat(subj,'selector','testsel' ,sel);  
