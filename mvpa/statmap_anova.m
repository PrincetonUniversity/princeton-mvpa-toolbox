function [subj] = statmap_anova(subj,data_patname,regsname,selname,new_map_patname,extra_arg)

% Use the anova to select features that vary between conditions
%
% [SUBJ] = STATMAP_ANOVA(SUBJ,DATA_PATNAME,REGSNAME,NEW_MAP_PATNAME);
%
% Adds the following objects:
% - statmap pattern object
%
% Updates the subject structure by creating a new pattern,
% NEW_MAP_PATNAME, that contains a vector of P-values from the ANOVA.
%
% Uses all the conditions in REGSNAME. If you only want to use a
% subset of them, create a new regressors object with only those
% conditions
%
% Only uses those TRs labelled with a 1 in the SELNAME selector,
% and where there's an active condition in the REGSNAME regressors matrix
%
% There should be functionality in here for return the F values as
% well (e.g. an optional argument 'MAP_TYPE' that defaults to 'p') xxx
%
% The EXTRA_ARG is completely useless here. All statmaps that can
% be used by FEATURE_SELECT have to take it though


if ~isempty(extra_arg)
  warning('Ignoring extra_arg');
end

pat  = get_mat(subj,'pattern',data_patname);
regs = get_mat(subj,'regressors',regsname);
sel  = get_mat(subj,'selector',selname);

sanity_check(pat,regs,sel);

TRs_to_use = find(sel==1);

pat   = pat(:,TRs_to_use);
regs = regs(:,TRs_to_use);

% Do all the hard work inside STATMAP_ANOVA_LOGIC
p = statmap_anova_logic(pat,regs);

% Now create a new pattern object to house the statmap with the p
% values in it
subj = init_object(subj,'pattern',new_map_patname);
subj = set_mat(subj,'pattern',new_map_patname,p);

% Every pattern needs to know which mask it is masked by
masked_by = get_objfield(subj,'pattern',data_patname,'masked_by');
subj = set_objfield(subj,'pattern',new_map_patname,'masked_by',masked_by);

hist = sprintf('Created by statmap_anova',data_patname);
subj = add_history(subj,'pattern',new_map_patname,hist);

created.function = 'statmap_anova';
created.data_patname = data_patname;
created.regsname = regsname;
created.selname = selname;
subj = add_created(subj,'pattern',new_map_patname,created);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [p] = statmap_anova_logic(pat,regs)

% -- building of vector conds and vector groups

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
p=zeros(nVox,1);
 
for j=1:nVox
  if mod(j,10000) == 0
    % disp( sprintf('anova on %i of %i',j,nVox) );
    fprintf('.');
  end
  p(j) = anova1(pat(j,dataIdx'),groups,'off');
end   


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [] = sanity_check(pat,regs,sel)

% Check that your regressors are in the correct 1-of-n form
[isbool isrest isoveractive] = check_1ofn_regressors(regs);
if ~isbool | isoveractive
  error('Your regressors aren''t in 1-of-n form');
end

if size(pat,2) ~= size(regs,2)
  error('Wrong number of timepoints');
end

if size(pat,2) ~= size(sel,2)
  error('Wrong number of timepoints');
end

if ~isrow(sel)
  error('Your selector needs to be a row vector');
end

if max(sel)>2 | min(sel)<0
  disp('These selectors don''t look like cross-validation selectors');
  disp('Are you feeding in your runs by accident?');
  error('This is almost certainly an error');
end

if ~length(find(regs)) | ~length(find(sel))
  error('There''s nothing for the ANOVA to run on');
end
