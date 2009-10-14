function [subj] = scramble_regressors(subj,regsname,selname,new_regsname)

% Scrambles your regressors for sanity-checking
%
% [SUBJ] = SCRAMBLED_REGRESSORS(SUBJ,REGSNAME,SELNAME,NEW_REGSNAME)
%
% It takes as inputs:
% SUBJ = the subj structure
% REGSNAME = the name of the regressors you want to scramble
% SELNAME = the selector that you want to constrain your scrambling
% by.  Usually you will want to scramble within runs, so that you
% have the same number of timepoints in each run. Therefore,
% reference your 'runs' variable for the selname
% NEW_REGSNAME = the name you want to give your new scrambled
% regressors matrix 

regs = get_mat(subj,'regressors',regsname);
runs = get_mat(subj,'selector',selname);

nruns = max(runs);

% These next lines will shuffle your regressors within each run

for i = 1:nruns
  thisrun = find(runs == i);
  regs(:,thisrun) = shuffle(regs(:,thisrun),2);
end

subj = duplicate_object(subj,'regressors',regsname,new_regsname);
subj = set_mat(subj,'regressors',new_regsname,regs);

hist = sprintf('Regressors ''%s'' created by scramble_regressors',new_regsname);
subj = add_history(subj,'regressors',new_regsname,hist,true);

created.function = 'scramble_regressors';
created.regsname = regsname;
created.selname = selname;
subj = add_created(subj,'regressors',new_regsname,created);
