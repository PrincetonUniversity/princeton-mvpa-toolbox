function [subj] = create_balanced_xvalid_selectors(subj,regsname,old_selname,varargin)

% [SUBJ] = CREATE_BALANCED_XVALID_SELECTORS(SUBJ,REGSNAME,OLD_SELNAME, ...)
%
% Run this after CREATE_XVALID_INDICES. This takes in the
% selector group OLD_SELNAME consisting of training and testing
% selectors, and balances the conditions within both
% training and testing for each iteration.
%
% See BALANCE_ACTIVE_SELECTOR for more information on the
% balancing procedure.
%
%   N.B. I think BALANCE_ACTIVE_SELECTOR
%   gets rid of rest from the selector...
%
%   As per BALANCE_ACTIVE_SELECTOR, CONDS must be binary
%   and not overactive.
%
% Creates a new selector group NEW_SELNAME.
%
% NEW_SELNAME (optional, default = sprintf('%s_bal')).
%
% e.g. subj = create_balanced_xvalid_selectors(subj,'regs','xval')


defaults.new_selname = sprintf('%s_bal',old_selname);
args = propval(varargin,defaults);
args_into_workspace;

conds = get_mat(subj,'regressors',regsname);
selmat = get_group_as_matrix(subj,'selector',old_selname);

[nIterations nTimepoints] = size(selmat);

[subj new_selnames] = duplicate_group(subj,'selector',old_selname,new_selname);

for i=1:nIterations
  % current selector iteration row vector
  sel = selmat(i,:);
  
  % logical vectors of just the training, and just the
  % testing parts
  trnsel = sel==1;
  tstsel = sel==2;
  
  trnsel_bal = balance_active_selector(conds,trnsel);
  tstsel_bal = balance_active_selector(conds,tstsel);

  % now recombine the newly balanced training and testing selectors
  new_sel = trnsel_bal*1 + tstsel_bal*2;
  
  new_selname = new_selnames{i};

  subj = set_mat(subj,'selector',new_selname,new_sel);
  
end % i nIterations


