function [] = check_1ofn_regressors_subj(subj,regsname,xval_selname)

% [] = CHECK_1OFN_REGRESSORS_SUBJ(SUBJ,REGSNAME,XVAL_SELNAME)
%
% wrapper for check_1ofn_regressors that also takes in a
% group of xvalid selector indices, to confirm that your
% regressors won't elicit 1-of-n warnings

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


regs = get_mat(subj,'regressors',regsname);

xval_members = find_group_single(subj,'selector',xval_selname);

for m=1:length(xval_members)
  xval_sel = get_mat(subj,'selector',xval_members{m});
  
  train_idx = find(xval_sel==1);
  test_idx  = find(xval_sel==2);

  test_regs(regs,train_idx);
  test_regs(regs,test_idx);
  
end % m



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [] = test_regs(regs,idx)

regs_subset  = regs(:,idx);

[isbool isrest isoveractive] = check_1ofn_regressors(regs_subset);
if ~isbool || isrest || isoveractive
  error('One of your regressors raised a 1-of-n warning');
end
