function [errmsgs warnmsgs] = test_statmap_anova()


% USAGE :[ERRMSGS WARNMSGS] = TEST_VOXEL_STATMAP_AONVA()
% 
% This is a script that tests the anova voxel selection method.
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

regs = [1 1 1 1 1 0 0 0 0 0 0 0 0 0 0; 0 0 0 0 0 1 1 1 1 1 0 0 0 0 0 ; 0 0 0 0 0 0 0 0 0 0 1 1 1 1 1];
sel = [1 1 1 1 1 1 1 1 1 1 1 1 1 1 1];

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

fake_data = fake_data + (0.45 * rand(30,15));


% plot stuff
imagesc(fake_data);

desired = repmat(1:10,1,3);
subj  = makesubj(fake_data,regs,sel);

% calling the statmap function
extra_arg='';
[subj] =   statmap_anova(subj,'testdata','testregs','testsel','test_map',extra_arg);

% checking...
correlation_val = corr(desired',subj.patterns{2}.mat)
if correlation_val <= 0.3
  error('correlation test failed');
end

clear subj;

%%%%%%%%% make a subj structure %%%%%%%%%%%%%%%%%%%%%%%%
function subj  = makesubj(data, regs,sel)

subj = init_subj('test_voxel_selection','testsubj');  
subj = init_object(subj,'pattern','testdata');
subj = set_mat(subj,'pattern','testdata' ,data);  

subj = init_object(subj,'regressors','testregs');
subj = set_mat(subj,'regressors','testregs' ,regs);  

subj = init_object(subj,'selector','testsel');
subj = set_mat(subj,'selector','testsel' ,sel);  




