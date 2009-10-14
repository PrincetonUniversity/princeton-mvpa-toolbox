function [errmsgs warnmsgs] = unit_traintest_corr()

% [ERRMSGS WARNMSGS] = UNIT_TRAINTEST_CORR()
%
% Tests that TRAIN/TEST_CORR are working correctly.
%
% Why doesn't this use GENERIC_UNIT_CLASSIFIER???
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

class_args.classifier = 'corr';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% i am going to create some randomdata and test it on the
% classifier.
regs = [1 1 1 0 0 0 1 1 1 0 0 0; 0 0 0 1 1 1 0 0 0 1 1 1];

pats = [1 1 1 5 5 5 1 1 1 5 5 5; 5 5 5 1 1 1 5 5 5 1 1 1;2 2 2 10 ...
	10 10 2 2 2 10 10 10; 10 10 10 2 2 2 10 10 10 2 2 2 ];

traintargs = regs(:,1:6);
trainpats = pats(:,1:6);
testtargs = regs(:,7:12);
testpats = pats(:,7:12);

scratchpad = train_corr(trainpats,traintargs,class_args,1);
[acts scratchpad] = test_corr(testpats,testtargs,scratchpad);
[perfmet] = perfmet_for_class_corr(acts,testtargs,scratchpad);  

% calculate the desired
%desired 
[max_vals max_idx] = max(corr(trainpats, testpats));
[max_val guesses]  = max(traintargs(:,max_idx));
[max_val actual] = max(testtargs);

corrects = guesses == actual;
desired_percent = length(find(corrects))/6;


if ~isequal(perfmet.perf,desired_percent)
  errmsgs{end+1} = 'Corr class Test :Failed-1';  
end

clear pats;clear regs;clear desired;clear scratchpad

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% i am going to create some randomdata and test it on the
% classifier.
regs = [1 1 1 0 0 0 1 1 1 0 0 0; 0 0 0 1 1 1 0 0 0 1 1 1];


pats = [1 1 1 5 5 5 1 1 1 5 5 5; 5 5 5 1 1 1 5 5 5 1 1 1;2 2 2 10 ...
	10 10 2 2 2 10 10 10; 10 10 10 2 2 2 10 10 10 2 2 2 ];


traintargs = regs(:,1:10);
trainpats = pats(:,1:10);
testtargs = regs(:,11:12);
testpats = pats(:,11:12);

scratchpad = train_corr(trainpats,traintargs,class_args,1);
[acts scratchpad] = test_corr(testpats,testtargs,scratchpad);
[perfmet] = perfmet_for_class_corr(acts,testtargs,scratchpad);  

% calculate the desired
%desired 
[max_vals max_idx] = max(corr(trainpats, testpats));
[max_val guesses]  = max(traintargs(:,max_idx));
[max_val actual] = max(testtargs);

corrects = guesses == actual;
desired_percent = length(find(corrects))/size(testtargs,2);

if ~isequal(perfmet.perf,desired_percent)
  errmsgs{end+1} = 'Corr class Test :Failed-2';  
end

clear pats;clear regs;clear desired;clear scratchpad;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% i am going to create some randomdata and test it on the
% classifier.
regs = [1 1 1 0 0 0 1 1 1 0 0 0; 0 0 0 1 1 1 0 0 0 1 1 1];
pats = [1 1 1 5 5 5 1 1 1 5 5 5; 5 5 5 1 1 1 5 5 5 1 1 1;2 2 2 10 ...
	10 10 2 2 2 10 10 10; 10 10 10 2 2 2 10 10 10 2 2 2 ];

% using different regressors
a = [1 2 3 4 5 4 3 2 1];
b = [1 1 1 1 1 1 ];
c = conv(a,b);

for i=1:2
  newregs(i,:) =  conv(regs(i,:),c);
end

regs = newregs;
noise =  rand(size(pats));
pats = pats + noise;


traintargs = regs(:,1:10);
trainpats = pats(:,1:10);
testtargs = regs(:,11:12);
testpats = pats(:,11:12);

scratchpad = train_corr(trainpats,traintargs,class_args,1);
[acts scratchpad] = test_corr(testpats,testtargs,scratchpad);
[perfmet] = perfmet_for_class_corr(acts,testtargs,scratchpad);  

% calculate the desired
%desired 
[max_vals max_idx] = max(corr(trainpats, testpats));
[max_val guesses]  = max(traintargs(:,max_idx));
[max_val actual] = max(testtargs);

corrects = guesses == actual;
desired_percent = length(find(corrects))/size(testtargs,2);

perfmet.perf
desired_percent

if ~isequal(perfmet.perf,desired_percent)
  errmsgs{end+1} = 'Corr class Test :Failed-3';  
end


clear pats;clear regs;clear desired;clear scratchpad;
