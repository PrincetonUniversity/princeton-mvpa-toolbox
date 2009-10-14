function [errmsgs warnmsgs] = test_remove_singletons()

% Unit test for remove_singletons
%
% [ERRMSGS WARNMSGS] = TEST_REMOVE_SINGLETONS();
%
% this function creates all kinds of crazy masks and tests the
% remove_singletons function


%initialising the *msgs cell arrays
errmsgs = {}; 
warnmsgs = {};

try
  subj = remove_singletons();
  errmsgs{end+1} = 'No arguments test:failed';
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TEST 1
% one voxel
mask = zeros(3,3,3);
mask(1,1,1) = 1;

subj= makesubj(mask);

% there is  a sanity check for this in the function so it shouldnt work
try
  subj = remove_singletons(subj,'testmask');
  errmsgs{end+1}= ('Works for one voxel hence TEST FAILED');
end  

clear subj;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TEST 2
% no voxels
mask = zeros(3,3,3);
subj= makesubj(mask);

% there is  a sanity check for this in the function so it shouldnt work
try
  subj = remove_singletons(subj,'testmask');
  errmsgs{end+1}= ('Works for zero voxel mask hence TEST FAILED');
end  

clear subj;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TEST 3
% all voxels
mask = ones(10,10,10);
subj= makesubj(mask);

desired = mask;

subj = remove_singletons(subj,'testmask');
createdmask = get_mat(subj,'mask','testmask_clustmask_1');

if ~isequal(desired, createdmask)
 errmsgs{end+1} = 'All voxels mask test : Failed';
end

clear subj;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TEST 4
% cuboidal mask

mask = ones(2,3,4);
subj= makesubj(mask);

desired = mask;

subj = remove_singletons(subj,'testmask');
createdmask = get_mat(subj,'mask','testmask_clustmask_1');

if ~isequal(desired, createdmask)
 errmsgs{end+1} = 'Assymetrical mask test : Failed';
end

clear subj;

  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TEST 5
% two corner voxels

mask = zeros(3,3,3);
mask(1,1,1)=1;
mask(3,3,3)=1;
subj= makesubj(mask);

desired = zeros(3,3,3);

subj = remove_singletons(subj,'testmask');
createdmask = get_mat(subj,'mask','testmask_clustmask_1');

if ~isequal(desired, createdmask)
 errmsgs{end+1} = ' Two opposite corner voxels test : Failed';
end

clear subj;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TEST 6
% two voxels next to each other

mask = zeros(3,3,3);
mask(1,1,1)=1;
mask(1,2,1)=1;
subj= makesubj(mask);
desired = mask;

subj = remove_singletons(subj,'testmask');
createdmask = get_mat(subj,'mask','testmask_clustmask_1');

if ~isequal(desired, createdmask)
 errmsgs{end+1} = 'Two neighbouring voxel test : Failed';
end

clear subj;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TEST 7
% one layer all voxels
mask = zeros(3,3,3);
mask(:,:,1) = 1;
subj= makesubj(mask);
desired = mask;

subj = remove_singletons(subj,'testmask');
createdmask = get_mat(subj,'mask','testmask_clustmask_1');

if ~isequal(desired, createdmask)
 errmsgs{end+1} = 'One layers of voxels test : Failed ';
end

clear subj;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TEST 8
% when there is a clump of voxels.  
mask = zeros(5,5,5);
mask(:,:,2) = 1;
mask(:,:,3) = 1;
subj= makesubj(mask);

desired = mask;

subj = remove_singletons(subj,'testmask');
createdmask = get_mat(subj,'mask','testmask_clustmask_1');

if ~isequal(desired, createdmask)
 errmsgs{end+1} = 'Clump of voxels test : Failed';
end
clear subj;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TEST 9
% 5 voxels scattered all over the place.
mask = zeros(5,5,5);

mask(1,1,1)=1;
mask(3,3,3)=1;
mask(5,5,5)=1;
mask(1,5,1)=1;
mask(5,1,5)=1;
subj= makesubj(mask);

desired = zeros(5,5,5);

subj = remove_singletons(subj,'testmask');
createdmask = get_mat(subj,'mask','testmask_clustmask_1');

if ~isequal(desired, createdmask)
 errmsgs{end+1} = 'Scattered Voxel Test : Failed';
end

clear subj;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TEST 10
% 5 voxels scattered all over the place but with a bigger cluster size
mask = zeros(5,5,5);

mask(1,1,1)=1;
mask(3,3,3)=1;
mask(5,5,5)=1;
mask(1,5,1)=1;
mask(5,1,5)=1;
subj= makesubj(mask);

desired = zeros(5,5,5);

subj = remove_singletons(subj,'testmask','clust_size', 25);
createdmask = get_mat(subj,'mask','testmask_clustmask_1');

if ~isequal(desired, createdmask)
 errmsgs{end+1} = 'Different clust_size test : Failed';
end

clear subj;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TEST 11
% 3 voxels cluster  but with a cluster size of 3
mask = zeros(3,3,3);

mask(1,1,1)=1;
mask(1,2,1)=1;
mask(2,1,1)=1;

subj= makesubj(mask);
desired = zeros(3,3,3);

subj = remove_singletons(subj,'testmask','clust_size', 3);
createdmask = get_mat(subj,'mask','testmask_clustmask_1');

if ~isequal(desired, createdmask)
 errmsgs{end+1} = '3 Voxels, clust_size=3  test : Failed';
end

clear subj;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TEST 12
% 6 voxel 2 layer cluster but with a cluster size of 5
mask = zeros(3,3,3);
mask(:,:,2) = 1;
mask(:,:,3) = 1;

subj= makesubj(mask);
desired = mask;

subj = remove_singletons(subj,'testmask','clust_size', 5);
createdmask = get_mat(subj,'mask','testmask_clustmask_1');

if ~isequal(desired, createdmask)
 errmsgs{end+1} = '2 layers of voxels, clust_size=5  test : Failed';
end

clear subj;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TEST 13
% 6 voxel 2 layers cluster but with a cluster size of 18
mask = zeros(3,3,3);
mask(:,:,2) = 1;
mask(:,:,3) = 1;

subj= makesubj(mask);
desired = zeros(3,3,3);

subj = remove_singletons(subj,'testmask','clust_size', 18);
createdmask = get_mat(subj,'mask','testmask_clustmask_1');

if ~isequal(desired, createdmask)
 errmsgs{end+1} = '2 layers of voxels, clust_size=18  test : Failed';
end

clear subj;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TEST 14
% 6 voxel 2 layers cluster but with a cluster size of 12
mask = zeros(3,3,3);
mask(:,:,2) = 1;
mask(:,:,3) = 1;

subj= makesubj(mask);
desired = zeros(3,3,3);
desired(2,2,2)=1;
desired(2,2,3)=1;

subj = remove_singletons(subj,'testmask','clust_size', 12);
createdmask = get_mat(subj,'mask','testmask_clustmask_1');

if ~isequal(desired, createdmask)
 errmsgs{end+1} = '2 layers of voxels, clust_size=12  test : Failed';
end
clear subj;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function subj  = makesubj(mask)
subj = init_subj('test_remove_singletons','testsubj');  
subj = init_object(subj,'mask','testmask');
subj = set_mat(subj,'mask','testmask' ,mask);  

