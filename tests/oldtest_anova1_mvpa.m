function [success errmsg] = test_anova1_mvpa(subj)

% [SUCCESS ERRMSG] = TEST_ANOVA1_MVPA()
%
% Test whether ANOVA1_MVPA.M gives exactly the same results as
% ANOVA1.M with various scenarios


success = -1;
errmsg = 'script unfinished'
return

success = 0;
errmsg = '';

if isempty(which('anova1'))
  errmsg = 'No Stats toolbox zscore to compare it to';
  success = -1;
  return
end

success = 1;

subj = anovatest_tutorial_easy(subj);

conds = get_mat(subj,'regressors','conds');

epi_z = get_mat(subj,'pattern','epi_z');
success = do_test(epi_z,conds);

disp('After the only test we actually care about');
keyboard

epi_z_nans = get_mat(subj,'pattern','epi_z_nans');
success = do_test(epi_z_nans,conds);

epi_z_zerorow = get_mat(subj,'pattern','epi_z_zerorow');
success = do_test(epi_z_zerorow,conds);

epi_z_zerocol = get_mat(subj,'pattern','epi_z_zerocol');
success = do_test(epi_z_zerorow,conds);

epi_z_novariancerow = get_mat(subj,'pattern','epi_z_novariancerow');
success = do_test(epi_z_zerorow,conds);

epi_z_novariancecol = get_mat(subj,'pattern','epi_z_novariancecol');
success = do_test(epi_z_zerorow,conds);

epi_z_novarianceingrp = get_mat(subj,'pattern','epi_z_novarianceingrp');
success = do_test(epi_z_novarianceingrp,conds);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [success] = do_test(data,regs);

success = 1;

try
  p_mathw = run_mathworks_anova(data,regs);
catch
  success = -1;
  disp('Caught error in anova mathw');
  return
end
 
try
  p_mvpa = 1 - anova1_mvpa(data,regs,ones([1 size(regs,2)]));
catch
  success = -1;
  disp('Caught error in anova mvpa');
end

if corr(p_mathw, ~isequal(p_mathw,p_mvpa))
  success = 0;
  error('Failed test');
  return
end




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [p] = run_mathworks_anova(pat,regs)

nVox    = size(pat,1);
nConds  = size(regs,1); 
groups  = [];
dataIdx = [];

for c=1:nConds
  theseIdx = find(regs(c,:)==1);
  dataIdx  =[dataIdx,theseIdx];
  groups   =[groups,repmat(c,1,length(theseIdx))];
end

% run the anova and save the p's
p = zeros(nVox,1);

for j=1:nVox
  p(j) = anova1(pat(j,dataIdx'),groups,'off');
end   



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [subj] = anovatest_tutorial_easy(subj)


subj = duplicate_object(subj,'pattern','epi_z','epi_z_nans');
epi_z_nans = get_mat(subj,'pattern','epi_z_nans');
epi_z_nans(1,:) = NaN;
subj = set_mat(subj,'pattern','epi_z_nans',epi_z_nans);

subj = duplicate_object(subj,'pattern','epi_z','epi_z_zerorow');
epi_z_zerorow = get_mat(subj,'pattern','epi_z_zerorow');
epi_z_zerorow(1,:) = 0;
subj = set_mat(subj,'pattern','epi_z_zerorow',epi_z_zerorow);

subj = duplicate_object(subj,'pattern','epi_z','epi_z_zerocol');
epi_z_zerocol = get_mat(subj,'pattern','epi_z_zerocol');
epi_z_zerocol(:,1) = 0;
subj = set_mat(subj,'pattern','epi_z_zerocol',epi_z_zerocol);

subj = duplicate_object(subj,'pattern','epi_z','epi_z_novariancerow');
epi_z_novariancerow = get_mat(subj,'pattern','epi_z_novariancerow');
epi_z_novariancerow(:,1) = pi;
subj = set_mat(subj,'pattern','epi_z_novariancerow',epi_z_novariancerow);

subj = duplicate_object(subj,'pattern','epi_z','epi_z_novariancecol');
epi_z_novariancecol = get_mat(subj,'pattern','epi_z_novariancecol');
epi_z_novariancecol(:,1) = pi;
subj = set_mat(subj,'pattern','epi_z_novariancecol',epi_z_novariancecol);

subj = duplicate_object(subj,'pattern','epi_z','epi_z_novarianceingrp');
conds = get_mat(subj,'regressors','conds');
conds1 = find(conds(1,:));
epi_z_novarianceingrp = get_mat(subj,'pattern','epi_z_novarianceingrp');
epi_z_novarianceingrp(1,conds1) = pi;
subj = set_mat(subj,'pattern','epi_z_novarianceingrp',epi_z_novarianceingrp);



