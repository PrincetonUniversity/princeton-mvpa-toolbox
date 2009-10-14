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

% License:
%=====================================================================
%
% This is part of the Princeton MVPA toolbox, released under
% the GPL. See http://www.csbmb.princeton.edu/mvpa for more
% information.
% 
% The Princeton MVPA toolbox is available free and
% unsupported to those who might find it useful. We do not
% take any responsibility whatsoever for any problems that
% you have related to the use of the MVPA toolbox.
%
% ======================================================================


%%%%%%%%%%%%%
%Original Code.
ones_zeros = length(find(regressors==1)) + length(find(regressors==0));
if ones_zeros ~= numel(regressors)
  % Some of your regressors aren''t one or zero');
  isbool = false;
else
  isbool = true;
end
  
% Now check each column (timepoint) to see how many active
% conditions there are

sum_regressors = sum(regressors~=0,1);

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

%{
%% Perform the default setup

isbool = true;
isrest = false;
isoveractive = false;

%% Detect Whether Regressors are Binary.

ones_zeros = length(find(regressors==1)) + length(find(regressors==0));
if ones_zeros ~= numel(regressors)
  % Some of your regressors aren''t one or zero');
  isbool = false;
end

%% Detect whether or not there are any empty columns or overfilled ones.

[reg_x, reg_y] = size(regressors);

for y = 1:reg_y
    
    temp_count = count(regressors(:,y));
    if temp_count == 0
        isrest = true;
    end
    
    if temp_count > 1
        isoveractive = true;
    end
    
end
%}

