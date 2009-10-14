function [isbool isrest isoveractive] = check_1ofn_regressors(regressors)

% Tells you about your regressors matrix
%
% [isbool isrest isoveractive] = check_1ofn_regressors(regressors)
%
% ISBOOL - true if all the regressors are 1s and 0s
%
% ISREST - true if some rest is included, i.e. some timepoints
% don't have an active condition
%
% ISOVERACTIVE - true if some timepoints have more than one active
% condition
%
% It's up to the caller function to decide what form it wants the
% regressors to take


ones_zeros = length(find(regressors==1)) + length(find(regressors==0));
if ones_zeros ~= numel(regressors)
  % Some of your regressors aren''t one or zero');
  isbool = false;
else
  isbool = true;
end
  
% Now check each column (timepoint) to see how many active
% conditions there are
sum_regressors = sum(regressors,1);

rests = find(sum_regressors==0);
overactives = find(sum_regressors>1);

if length(rests)
  isrest = true;
else
  isrest = false;
end

if length(overactives)
  isoveractive = true;
else
  isoveractive = false;
end




