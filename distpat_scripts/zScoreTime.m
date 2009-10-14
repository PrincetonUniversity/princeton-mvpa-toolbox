function [subj] = zScoreTime(subj)
% function [subj] = zScoreTime(subj)
% 
% zScore over time.  Sets mean equal to zero and variance to 1 by
% voxel.  Separate zscore for each run.
%
% *** THIS VERSION HAS NOT BEEN DEBUGGED OR TESTED
% (please remove these lines once you test it)
%
% *** THIS VERSION IS 11/18/04

for r = 1:max(subj.runs)
  % here are all the timepoints that appear in this run
  foundRuns = find(subj.runs == r);
  
  % zscore works on columns
  % we want a zscore on rows
  % so we transpose
  subj.data(:,foundRuns) = zscore(subj.data(:,foundRuns)')';
  
end % for runs
  
% add a remark in the header
string = strcat('zscore by vox, zScoreTime',':',date);
subj = addheader(subj,string);



      
