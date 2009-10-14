function [errmsgs warnmsgs] = unit_interpret_weights()

% [ERRMSGS WARNMSGS] = UNIT_INTERPRET_WEIGHTS()
%
% Creates a really simple dataset, runs multiple
% cross_validations with BP on it, and then checks that
% interpret weights gives roughly the right output. This
% isn't a complete set of checks, but should pick up
% egregious problems.
%
% nCrossValids (optional, default = 5). The number of times to run
% cross validation
%
% UPDATE (GJD 080329): on looking over these, i'm not sure
% that these tests really do confirm that things are working
% in a very comprehensive way. It looks as though they run
% the simulations, then replace the weights with what's
% expected, and then test the output of INTERPRET_WEIGHTS
% against the desired weights...


errmsgs = {}; 
warnmsgs = {};

%%%%%%%%%%%%%%% TEST all %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% creating new data.
regs = [1 1 1 1 1 0 0 0 0 0 1 1 1 1 1 0 0 0 0 0; ...
        0 0 0 0 0 1 1 1 1 1 0 0 0 0 0 1 1 1 1 1 ];
runs = [1 1 1 1 1 1 1 1 1 1 2 2 2 2 2 2 2 2 2 2 ];
nVox = 8; nRuns=2;nConds = 2;
pat = [ repmat(regs(1,:),4,1);repmat(regs(2,:),4,1)];
pat = [1:nVox]' * pat(1,:);
mask = ones([2 2 2]);
nCrossValids=5;

% creating the subj structure and running the cross validation function
[subj,results] = my_cross_val(pat,regs,runs,mask,nCrossValids);


% now i convert the results structure whatever i want in to be so
% that i can see what my desired output should be.
for i=1:nCrossValids
  for j=1:nRuns  
    results{i}.iterations(j).scratchpad.net.IW{1} = ones(nConds,nVox);
  end %i
end %j

[subj] = interpret_weights(subj,results);

desired = [[1:8]',[1:8]'*0];

if ~isequal(desired,  get_mat(subj,'pattern', 'impmap_1'))
  errmsgs('Simple all test:failed');  
end

if ~isequal(desired,  get_mat(subj,'pattern', 'impmap_2'))
    errmsgs('Simple all test:failed');  
end

clear subj;
clear results;

%%%%%%%%%%%%%%% TEST all but with different weights for each of the
%conditions. For all the other tests i am keeping the weights per
% both the conditions per voxel the same %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% creating new data.
regs = [1 1 1 1 1 0 0 0 0 0 1 1 1 1 1 0 0 0 0 0; ...
        0 0 0 0 0 1 1 1 1 1 0 0 0 0 0 1 1 1 1 1 ];
runs = [1 1 1 1 1 1 1 1 1 1 2 2 2 2 2 2 2 2 2 2 ];
nVox = 8; nRuns=2;nConds = 2;
pat = [repmat(regs(1,:),4,1);repmat(regs(2,:),4,1)];
pat = [1:nVox]' * pat(1,:);

pat(:,6:10)= pat(:,1:5)*2;
pat(:,16:20) = pat(:,1:5)*2;

mask = ones([2 2 2]);
nCrossValids=5;

% creating the subj structure and running the cross validation function
[subj,results] = my_cross_val(pat,regs,runs,mask,nCrossValids);

% now i convert the results structure whatever i want in to be so
% that i can see what my desired output should be.
for i=1:nCrossValids
  for j=1:nRuns  
    results{i}.iterations(j).scratchpad.net.IW{1}(1,:) = ones(1,nVox);
    results{i}.iterations(j).scratchpad.net.IW{1}(2,:) = ones(1,nVox)*0.5; 
  end %i
end %j

% runs the interpret_weights function
[subj] = interpret_weights(subj,results);
% desired_1 = first iteration of the nminusone, nVox x nConds
desired_1 = [[1:8]',[1:8]'*1];
desired_2 = [[1:8]',[1:8]'*2*0.5];


if ~isequal(desired_1,get_mat(subj,'pattern', 'impmap_1'))
  errmsgs('Simple all test but 2 different results 1 :failed');  
end

if ~isequal(desired_2,  get_mat(subj,'pattern', 'impmap_2'))
    errmsgs('Simple all test but 2 different results 2 :failed');  
end

clear subj;
clear results;

%%%%%%%%%%%%%%% TEST for pos when data is negative %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% creating new data.
regs = [1 1 1 1 1 0 0 0 0 0 1 1 1 1 1 0 0 0 0 0; ...
        0 0 0 0 0 1 1 1 1 1 0 0 0 0 0 1 1 1 1 1 ];
runs = [1 1 1 1 1 1 1 1 1 1 2 2 2 2 2 2 2 2 2 2 ];
nVox = 8; nRuns=2;nConds = 2;
temppat = [ repmat(regs(1,:),4,1);repmat(regs(2,:),4,1)];
pat(1:4,:) = [1:4]' * temppat(1,:)*-1;
pat(5:8,:) = [5:8]' * temppat(1,:);

mask = ones([2 2 2]);
nCrossValids=5;

% creating the subj structure and running the cross validation function
[subj,results] = my_cross_val(pat,regs,runs,mask,nCrossValids);


% now i convert the results structure whatever i want in to be so
% that i can see what my desired output should be.
for i=1:nCrossValids
  for j=1:nRuns  
    results{i}.iterations(j).scratchpad.net.IW{1} = ones(nConds,nVox);
  end %i
end %j

% runs the interpret_weights function
[subj] = interpret_weights(subj,results,'type_canon','pos');

desired = [[1:8]',[1:8]'*0];
desired(1:4,:)= 0;


if ~isequal(desired,  get_mat(subj,'pattern', 'impmap_1'))
  errmsgs('Data negative: Pick only positive test:failed');  
end



if ~isequal(desired,  get_mat(subj,'pattern', 'impmap_2'))
  errmsgs('Data negative: Pick only positive test:failed');
end

clear subj;
clear results;


%%%%%%%%%%%%%%% TEST for pos when weights are negative %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% creating new data.
regs = [1 1 1 1 1 0 0 0 0 0 1 1 1 1 1 0 0 0 0 0; ...
        0 0 0 0 0 1 1 1 1 1 0 0 0 0 0 1 1 1 1 1 ];
runs = [1 1 1 1 1 1 1 1 1 1 2 2 2 2 2 2 2 2 2 2 ];
nVox = 8; nRuns=2;nConds = 2;
temppat = [ repmat(regs(1,:),4,1);repmat(regs(2,:),4,1)];
pat(1:4,:) = [1:4]' * temppat(1,:)*-1;
pat(5:8,:) = [5:8]' * temppat(1,:);

mask = ones([2 2 2]);
nCrossValids=5;

% creating the subj structure and running the cross validation function
[subj,results] = my_cross_val(pat,regs,runs,mask,nCrossValids);


% now i convert the results structure whatever i want in to be so
% that i can see what my desired output should be.
for i=1:nCrossValids
  for j=1:nRuns  
    results{i}.iterations(j).scratchpad.net.IW{1} = ones(nConds,nVox)*-1;
  end %i
end %j

% runs the interpret_weights function
[subj] = interpret_weights(subj,results,'type_canon','pos');
desired=zeros(8,2);

if ~isequal(desired, get_mat(subj,'pattern', 'impmap_1'))
  errmsgs('Weights negative: Pick only positive test:failed');  
end

if ~isequal(desired,  get_mat(subj,'pattern', 'impmap_2'))
    errmsgs('Weights negative: Pick only positive test:failed');  
end

clear subj;
clear results;

%%%%%%%%%%%%%%% TEST for all when when data for one condition is negatives %%%%%%%%%%
% creating new data.
regs = [1 1 1 1 1 0 0 0 0 0 1 1 1 1 1 0 0 0 0 0; ...
        0 0 0 0 0 1 1 1 1 1 0 0 0 0 0 1 1 1 1 1 ];
runs = [1 1 1 1 1 1 1 1 1 1 2 2 2 2 2 2 2 2 2 2 ];
nVox = 8; nRuns=2;nConds = 2;
pat = [ repmat(regs(1,:),4,1);repmat(regs(2,:),4,1)];
pat = [1:nVox]' * pat(1,:);
pat(:,6:10) = pat(:,1:5)*-1;
pat(:,16:20) = pat(:,1:5)*-1;
mask = ones([2 2 2]);
nCrossValids=5;

% creating the subj structure and running the cross validation function
[subj,results] = my_cross_val(pat,regs,runs,mask,nCrossValids);

% now i convert the results structure whatever i want in to be so
% that i can see what my desired output should be.
for i=1:nCrossValids
  for j=1:nRuns  
    results{i}.iterations(j).scratchpad.net.IW{1} = ones(nConds,nVox)*1;
  end %i
end %j

% runs the interpret_weights function
[subj] = interpret_weights(subj,results);
desired = [[1:8]'*1,[1:8]'*-1];

if ~isequal(desired, get_mat(subj,'pattern', 'impmap_1'))
  errmsgs('One Condition data negative: Pick all test:failed');  
end

if ~isequal(desired,  get_mat(subj,'pattern', 'impmap_2'))
    errmsgs('One Condition data negative: Pick all test:failed');  
end

clear subj;
clear results;

%%%%%%%%%%%%%%% TEST for pos when when data for one condition is negatives %%%%%%%%%%
% creating new data.
regs = [1 1 1 1 1 0 0 0 0 0 1 1 1 1 1 0 0 0 0 0; ...
        0 0 0 0 0 1 1 1 1 1 0 0 0 0 0 1 1 1 1 1 ];
runs = [1 1 1 1 1 1 1 1 1 1 2 2 2 2 2 2 2 2 2 2 ];
nVox = 8; nRuns=2;nConds = 2;
pat = [ repmat(regs(1,:),4,1);repmat(regs(2,:),4,1)];
pat = [1:nVox]' * pat(1,:);
pat(:,6:10) = pat(:,1:5)*-1;
pat(:,16:20) = pat(:,1:5)*-1;

mask = ones([2 2 2]);
nCrossValids=5;

% creating the subj structure and running the cross validation function
[subj,results] = my_cross_val(pat,regs,runs,mask,nCrossValids);

% now i convert the results structure whatever i want in to be so
% that i can see what my desired output should be.
for i=1:nCrossValids
  for j=1:nRuns  
    results{i}.iterations(j).scratchpad.net.IW{1} = ones(nConds,nVox)*1;
  end %i
end %j

% runs the interpret_weights function
[subj] = interpret_weights(subj,results,'type_canon','pos');

desired = [[1:8]',[1:8]'*0];

if ~isequal(desired, get_mat(subj,'pattern', 'impmap_1'))
  errmsgs('One Condition data negative: Pick pos test:failed');  
end

if ~isequal(desired,  get_mat(subj,'pattern', 'impmap_2'))
    errmsgs('One Condition data negative: Pick pos test:failed');  
end

clear subj;
clear results;


%%%%%%%%%%%%%%% TEST nImpmaps  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% creating new data.
regs = [1 1 1 1 1 0 0 0 0 0 1 1 1 1 1 0 0 0 0 0; ...
        0 0 0 0 0 1 1 1 1 1 0 0 0 0 0 1 1 1 1 1 ];
runs = [1 1 1 1 1 1 1 1 1 1 2 2 2 2 2 2 2 2 2 2 ];
nVox = 8; nRuns=2;nConds = 2;
temppat = [ repmat(regs(1,:),4,1);repmat(regs(2,:),4,1)];
pat(1:4,:) = [1:4]' * temppat(1,:)*-1;
pat(5:8,:) = [5:8]' * temppat(1,:);

mask = ones([2 2 2]);
nCrossValids=2;

% creating the subj structure and running the cross validation function
[subj,results] = my_cross_val(pat,regs,runs,mask,nCrossValids);

% now i convert the results structure whatever i want in to be so
% that i can see what my desired output should be.
for i=1:nCrossValids
  for j=1:nRuns  
    results{i}.iterations(j).scratchpad.net.IW{1} = ones(nConds,nVox)*-1;
  end %i
end %j

% runs the interpret_weights function
[subj] = interpret_weights(subj,results);

if ~isequal(nRuns,length(find_group(subj,'pattern','impmap')))
  errmsgs('No. of ImpMap test: Failed');  
end

clear subj;
clear results;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [subj, results] = my_cross_val(pat,regs,runs,mask,nCrossValids)

subj = init_subj('test_interpret_weights','testsubj');
subj = initset_object(subj,'regressors','regs',regs);
subj = initset_object(subj,'selector','runs',runs);
subj = initset_object(subj,'mask','themask',mask);
subj = initset_object(subj,'pattern','pat',pat, 'masked_by','themask');


subj = create_xvalid_indices(subj,'runs');
class_args.train_funct_name = 'train_bp';
class_args.test_funct_name = 'test_bp';
class_args.nHidden = 0;

for j=1:nCrossValids
  [subj results{j}] = cross_validation(subj,'pat','regs','runs_xval','themask',class_args);
end %j

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% expect a group of patterns called impmap

% impmap_names = find_group(subj,'pattern','impmap');

% if length(impmap_names) ~= nRuns
%   errors{end+1} = 'There should be nRuns importance maps';
% end

% all_impmaps = NaN(nVox,nConds,nRuns);

% for i=1:length(impmap_names)
%   impmap = get_mat(subj,'pattern',impmap_names{i});
%   all_impmaps(:,:,i) = impmap;
  
%   if ~isequal(size(impmap),[nVox nConds])
%     errors{end+1} = 'Importance map is the wrong size';
%   end
 
%   % in this very simple case, the importance map should look a lot
%   % like the original pattern. find the absolute difference between
%   % the two (on average for a voxel) - if it's more than some small
%   % amount, flag an error
%   if mean(mean(abs(impmap - pat)))>0.1
%     errors{end+1} = ['The importance map doesn''t look enough like' ...
% 		     ' the original pattern'];
%   end
  
% end % i





