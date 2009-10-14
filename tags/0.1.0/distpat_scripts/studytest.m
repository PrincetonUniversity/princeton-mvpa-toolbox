function [results] = studytest(subj,train_regress,test_regress)
% [results] = studytest(subj,train_regress,test_regress)
%
% classification wrapper script
% trains a network on the patterns specified by train_regress,
% using train_regress as targets.  tests the network on
% the patterns specified by test_regress, using test_regress as the
% targets.  
%
% train_regress and test_regress must have the same number of
% columns; furthermore, they columns must have a one-to-one
% correspondence.  Column 1 in train_regress and column 1 in
% test_regress are both associated with output unit 1 in the
% network.  
%
%
%
%

% define pats and targs for class_bp script
% pats are just train
% targs is regressors transposed
% the st script will train on train and test on test
trainpats = [];
traintargs = [];

testpats = [];
testtargs = [];


for i=1:size(train_regress,2)
  patIdx = find(train_regress(:,i)==1);
  trainpats = [trainpats,subj.data(:,patIdx)];
  traintargs = [traintargs,train_regress(patIdx,:)'];
end

for i=1:size(test_regress,2)
  patIdx = find(test_regress(:,i)==1);
  testpats = [testpats,subj.data(:,patIdx)];
  testtargs = [testtargs,test_regress(patIdx,:)'];
end

[out scratchpad subj.header] = call_classifier(classifier, ...
					class_args, ...
					trainpats, ...
					traintargs, ...
					testpats, ...
					testtargs, ...
					subj.header ...
					);

results.withheld(1).scratchpad = scratchpad;
results.withheld(1).out = out;

results.nWithhelds = length(results.withheld)    

disp( sprintf('results for n=1: %.2f',results.withheld(1).out.pct_correct) );

results.total_perf = results.withheld(1).out.pct_correct;


