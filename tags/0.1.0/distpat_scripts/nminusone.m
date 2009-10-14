function [subj,results] = nminusone(subj,classifier,class_args,varargin)

% [subj,results] = nminusone(subj,classifier,class_args,excludeRuns,regressors)
% Example:
% [subj,results] = nminusone(subj,'bp',class_args,[4],regs)
% This is a general nminusone script which can be used for any experiment 
% with any classifier.   
% subj - subject structure
% classifier - 'bp', 'gnb', 'rbf', 'log'   etc. see the individual classifier
% scripts for more info about what the various class_args
% structures need to contain - xxx
% class_args - see below
% excludeRuns - which runs to leave out of the nm1 algorithm
% (OPTIONAL)
% regressors - if you don't want to use subj.regressors, include
% this field. (OPTIONAL)
%
% results.withheld(i).out:
% -  confidences_cat_per_unit - test_timepoints x vox x cats - null if bp
% -  confidences_cats_across_units - test_timepoints x cats - give confidences for each category (summed over voxels)
% -  confidences_each_timepoint - test_timepoints - just the chosen cat and maybe its confidence
% -  chosen_each_timepoint - test_timepoints - which cat actually got chosen
% -  corrects_each_timepoint - same as above, but just rights + wrongs
% eventually, this should use eval to run the various classifier
% scripts according to the 'classifier' argument string (rather
% than all these if statements)
% For backprop class_args:
% class_args.layers = 2;
% class_args.performFcn = 'CrossEntropy';
% class_args.mask = 1;

% creating an rough array to exclude the run number that is not required.    

clear results;

if (nargin == 3)
  regressors = subj.regressors;
  excludeRuns = []; 
elseif(nargin == 4) 
  excludeRuns = varargin{1};
  regressors = subj.regressors;
elseif(nargin == 5)
  excludeRuns = varargin{1};
  regressors = varargin{2};
end


clear varargin;

for i=1:max(subj.runs);
  newRunarr(i) = i;
end

for j=1:size(excludeRuns),   
  newRunarr(find(newRunarr==excludeRuns(j)))=[];
end


results.nWithhelds = max(subj.runs)-length(excludeRuns);  % change : argument to specify which run to use.     
subtotal_perf = 0;

disp('starting n-1 analysis');

for i=1:length(newRunarr)
  
  withhold_this = newRunarr(i);
  include_these = newRunarr;
  include_these(i) = [];
  
  disp( sprintf('\twithholding run %i', withhold_this ))
  results.withheld(i).withheld_run = withhold_this;
  
  % create the training set and the testing set
  % targs should be nCond rows by time cols
  
  trainRunIdx = [];
  testRunIdx = [];

  for j = 1:length(include_these)
    trainRunIdx = [trainRunIdx, find(subj.runs==include_these(j))];
  end
  
  testRunIdx = find(subj.runs==withhold_this);
  
  % This version will not train or test on REST
  nonRestIdx = find(sum(regressors,2)~=0);
  
  trainIdx = intersect(trainRunIdx,nonRestIdx);
  testIdx = intersect(testRunIdx,nonRestIdx);
  results.withheld(i).trainIdx = trainIdx;
  results.withheld(i).testIdx = testIdx;
 
  trainpats = subj.data(:,trainIdx);
  traintargs = regressors(trainIdx,:)';
  testpats = subj.data(:,testIdx);
  testtargs = regressors(testIdx,:)';
  
  [out scratchpad subj.header] = call_classifier(classifier, ...
					  class_args, ...
					  trainpats, ...
					  traintargs, ...
					  testpats, ...
					  testtargs, ...
					  subj.header ...
					  );
  
  
  results.withheld(i).scratchpad = scratchpad;
  results.withheld(i).out = out;
  subtotal_perf = subtotal_perf + results.withheld(i).out.pct_correct;
  
  results.nWithhelds = size(results.withheld ,2)    

  disp( sprintf('results for n=%i: %.2f',i, ...
		results.withheld(i).out.pct_correct) );
  
end % for i=1:length(newRunarr)
results.total_perf = subtotal_perf / results.nWithhelds;

head = sprintf('did an nminusone using %s and got total_perf %.2f - %s', ...
		    classifier,results.total_perf,datetime());
subj = addheader(subj,head);
results = addresultsheader(results,head);

