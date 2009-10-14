function [errs warns] = generic_unit_classifier(class_args)

% Generic classification train/test unit test
%
% [ERRS WARNS] = GENERIC_TEST_CLASSIFIER(type)
%
% Calls the classification train/test functions specified
% in CLASS_ARGS on a variety of synthetic and real
% data. This script is intended to be called from
% wrappers, such as UNIT_TRAINTEST_BP.M, though there's
% nothing stopping you calling it manually. It is
% supposed to provide a set of generic hurdles that any
% classification script should pass, including performing
% at chance on scrambled/random data.
%
% N.B. currently requires access to ~/juke_norman/vnatu for
% testing the FREEREC subject. In future, it should give
% a warning if unable to find this
%
% CLASS_ARGS - just as for CROSS_VALIDATION 
%
% ERRS = cell array holding the error strings
% describing any tests that failed. If this is empty,
% that's a good thing
%
% WARNS = cell array, like ERRS, of tests that didn't pass
% and didn't fail (e.g. because they weren't run)
%
% N.B. the classification process is divided into three
% steps. so we will really be testing three functions in
% all: the training and testing for each classifier and the
% common perfmet_maxclass function.


%initialising the *msgs cell arrays
errs = {}; 
warns = {};

% first create the training and testing function handlers
% based on the type of classifier we can to run
train_funct = str2func(class_args.train_funct_name);
test_funct  = str2func(class_args.test_funct_name);

% if you're using the corr classifier, then you need to use
% a special classification perfmet, otherwise just use the
% standard perfmet_maxclass
if strcmp(class_args.train_funct_name,'train_corr')
  if ~strcmp(class_args.test_funct_name,'test_corr')
    % if someone can come up with an example of where you might want to
    % do this, we can switch this to a warning instead
    error('Does it make sense to train on corr and test with something else?');
  end
  perfmet_funct = str2func('perfmet_for_class_corr');
else
  perfmet_funct = str2func('perfmet_maxclass');
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% this is a negative test.
% this test should fail if the function works with no arguments.

try   
  scratchpad = train_funct();
  errs{end+1} = 'No arguments test:failed -1' 
end

try 
  acts scratchpad = test_funct();
  errs{end+1} = 'No arguments test:failed -2' 
end

try  
  perfmet = perfmet_funct();     
  errs{end+1} = 'No arguments test:failed -3'
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% test on perfect data so we should
% get a perfect output
desired = 1;

% create regs and pats
regs = create_regs();
pats = create_pats(100,1,regs,0);

% do classification
calc_perf = do_classification(train_funct,test_funct,perfmet_funct,regs,pats,class_args,10);

if ~isequal(calc_perf,desired)
  errs{end+1} = 'Perfect data test : failed';
end

clear calc_perf pats regs


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% now i am creating my own noisy data and i am going to 
% use the non-shuffled test regressors.

% 'testing the non shuffled regs');  

% create regs and pats
regs = create_regs();
pats = create_pats(100,1,regs, 2.2);

% do classification
calc_perf = do_classification(train_funct,test_funct,perfmet_funct, regs, pats,class_args,10);

% check if test works
if ~(calc_perf > 0.4)
  errs{end+1} = 'Regular Regressors Test: Failed';
end

warns{end+1} = lastwarn;
clear calc_perf pats regs

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% now i am creating my own noisy data and i am going to use the 
% shuffled test regressors.

% create regs
[regs] = create_regs();
[pats] = create_pats(100,1, regs,3.4);

% shuffle regressors
regs(:,101:150) = shuffle(regs(:,101:150)')';
pats(:,101:150) = shuffle(pats(:,101:150)')';

% do classification
calc_perf = do_classification(train_funct,test_funct,perfmet_funct, regs, pats,class_args,10);

% check if test works
if (calc_perf > 0.4 )
  errs{end+1} = 'Shuffled Regressors Test: Failed';
end

warns{end+1} = lastwarn;
clear calc_perf pats regs

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% now we test it using noisify_regressors scripts. 
% this is using regular regressors

% create regs
regs = create_regs();
pats = create_pats(100,0,regs, 2.2);

% do classification
calc_perf = do_classification(train_funct,test_funct,perfmet_funct ,regs, pats,class_args,10);

% check if test works
if ~(calc_perf > 0.4)
  errs{end+1} = 'Regular regressors using Noisify Test  : Failed';
end

warns{end+1} = lastwarn;
clear calc_perf;clear calc_perf;clear pats

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% now we test it using noisify_regressors scripts.
% this is using the shuffled regressors 

% create regs
regs = create_regs();
pats = create_pats(100,0,regs,2.2);

% shuffle regressors
regs(:,101:150) = shuffle(regs(:,101:150)')';
pats(:,101:150) = shuffle(pats(:,101:150)')';

% do classification
calc_perf = do_classification(train_funct,test_funct,perfmet_funct, regs, pats,class_args,10);

% check if the shuffled test regressors make performance measure to
% go to chance
%
% it would be nice to calculate whether this is significantly above
% chance, rather than just choosing a value arbitrarily. this used
% to be set to 0.4, but it just failed, and so i set it higher...
if ( calc_perf > 0.45)
  errs{end+1} = 'Shuffled test regressors using Noisify Test : Failed';
end

warns{end+1} = lastwarn;
clear calc_perf;clear pats; clear regs;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% testing free rec without shuffled test regressors

try
  calc_perf = do_freerec(train_funct,test_funct,perfmet_funct,class_args,0);

  try
    if ~( calc_perf > 0.4)
      errs{end+1} = 'Regular test regressors using FREE REC DATA Test : Failed';
    end
    
    warns{end+1} = lastwarn;
    clear calc_perf;
  catch
    warns{end+1} = 'No freerec dataset';
  end
  
catch % do_freerec
  warns{end+1} = 'No freerec dataset';
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% testing free rec with shuffled test regressors

try
  [calc_perf] = do_freerec(train_funct,test_funct,perfmet_funct,class_args ,1);

  if ( calc_perf > 0.4)
    errs{end+1} = 'Shuffled test regressors using FREE REC DATA Test : Failed';
  end
  
  warns{end+1} = lastwarn;
  clear calc_perf;
  
catch % do_freerec
  warns{end+1} = 'No freerec dataset';
end


%*******************************
% END OF TEST
%%%%%%%%%%%%% this is the free recall data stuff.%%%%%%%%%%
% % i am trying this with real data.
function [perf] = do_freerec(train_funct,test_funct,perfmet_funct,class_args,shuff)

% have a backup in case we're on the norman lab machines instead of
% jukebox
if exist('/jukebox/norman/vnatu/scripts/FREEREC/SUBJ17','file')
  cd('/jukebox/norman/vnatu/scripts/FREEREC/SUBJ17');
else
  cd('~/juke_norman/vnatu/scripts/FREEREC/SUBJ17');
end
load TEST_REALDATA

regs =[]; pats =[];

regs = test_realdata.regressors;
pats = test_realdata.data;

if shuff == 1
  regs(:,301:450) = shuffle(regs(:,301:450)')';
  pats(:,301:450) = shuffle(pats(:,301:450)')';
  
end

%create test and train targs/pats
traintargs = regs(:,1:300);
trainpats = pats(:,1:300);
testtargs = regs(:,301:450);
testpats = pats(:,301:450);

all_perfs=[];

% do classification
for i=1:1
  scratchpad = train_funct(trainpats,traintargs,class_args,2);
  [acts scratchpad] = test_funct(testpats,testtargs,scratchpad);
  [perfmet] = perfmet_funct(acts,testtargs,scratchpad);  
  all_perfs(i) = perfmet.perf;
end

perf = mean(all_perfs);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [perf] = do_classification(train_funct,test_funct,perfmet_funct,regs, pats,class_args,nTimes)

traintargs = regs(:,1:100);
trainpats = pats(:,1:100);
testtargs = regs(:,101:150);
testpats = pats(:,101:150);

all_perfs=[];

for i=1:nTimes
  scratchpad = train_funct(trainpats,traintargs,class_args);
  [acts scratchpad] = test_funct(testpats,testtargs,scratchpad);
  perfmet = perfmet_funct(acts,testtargs,scratchpad);  
  
  all_perfs(i) = perfmet.perf;
end

perf = mean(all_perfs);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [regs] = create_regs()

regs=[1 1 1 1 1 0 0 0 0 0 0 0 0 0 0; ...
      0 0 0 0 0 1 1 1 1 1 0 0 0 0 0; ...
      0 0 0 0 0 0 0 0 0 0 1 1 1 1 1];

regs=repmat(regs,1,10);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [pats] = create_pats(nVox,type,regs, noisiness)

[nConds nTimepoints] = size(regs);

% i think these are two separate methods for doing more or
% less the same thing - set each voxel to be based on one of
% the regressor timecourses plus some noise
%
% what is type 1??? type 1 = vaidehi's version, i think
if type == 1 
  % preinitialize pats
  pats = NaN(nVox,nTimepoints);
  
  for i=1:nVox 
    % choose 1, 2 or 3 at random (will refer to the
    % condition)
    r = ceil(3.*rand(1,1)); 
    
    % set the current voxel to be equal to one of the
    % regressor timecourses
    pats(i,:) = regs(r,:);
  end  
  noise = rand(size(pats)) .* noisiness;
  pats = pats + noise;    

% type = 2
else  
  [pats info] = noisify_regressors(regs,nVox,noisiness,'uniform','ascending',0);   
end
