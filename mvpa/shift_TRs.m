function [subj] = shift_TRs(subj,regsname,selname,nTRs)
% 
% [SUBJ] = SHIFT_TRS(SUBJ,REGSNAME,SELNAME,nTRs)
% 
% Shifts regressors ahead in time to account for hemodynamic lag.
% Modifies the regressors REGSNAME by shifting nTRs forward within
% each run specified by SELNAME. Those TRs at the end of a run are
% deleted.  TRs inserted at the beginning of each run default to 0.

% This is part of the Princeton MVPA toolbox, released under the
% GPL. See http://www.csbmb.princeton.edu/mvpa for more
% information.


% Load in the run selector and calculate its size
runs = get_mat(subj,'selector',selname);
nRuns = length(unique((runs(find(runs)))));

% Error Check: Make sure the runs regressor has no rest
if any(runs == 0)
  error('Runs regressor includes 0s. Cannot identify ends of run');
end

% Identify the last nTRs timepoints in each run
% Finds the TRs N, where run(TR) does not equal run(TR+n)
lTR  = find(runs(1:end-nTRs) ~= runs(nTRs+1:end));

% When the regressor is shifted, these last TRs from each run will
% become the first TRs from the next run. Set them to = 0
regs = get_mat(subj,'regressors',regsname);
regs(:,lTR) = 0;

% Now shift the entire regressor by inserting zeros, and then lop
% off the final nTRs 
regs = cat(2, zeros(size(regs,1), nTRs), regs(:,1:end-nTRs));

% Now save the new regressors back into the regressor object
subj = set_mat(subj,'regressors',regsname,regs);

