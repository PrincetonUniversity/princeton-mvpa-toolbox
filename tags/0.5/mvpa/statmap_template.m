function [subj] = statmap_template(subj,data_patname,regsname,selname,new_map_patname,extra_arg)

% This is the sample/template statmap generation function
%
% [SUBJ] = STATMAP_TEMPLATE(SUBJ,DATA_PATNAME,REGSNAME,SELNAME,NEW_MAP_PATNAME,EXTRA_ARG)
%
% Adds the following objects:
% - statmap pattern object
%
% Updates the subject structure by creating a new pattern,
% NEW_MAP_PATNAME, that contains a vector of P-values (for example)
%
% See STATMAP_ANOVA for a real example script
%
% Uses all the conditions in REGSNAME. If you only want to use a
% subset of them, create a new regressors object with only those
% conditions
%
% Only uses those TRs labelled with a 1 in the SELNAME selector,
% and where there's an active condition in the REGSNAME regressors matrix
%
% All statmaps that can be used by FEATURE_SELECT have to take the
% extra_arg which can store any info your statmap might need
%
% See the section on creating your own statmap in the manual


pat  = get_mat(subj,'pattern',data_patname);
regs = get_mat(subj,'regressors',regsname);
sel  = get_mat(subj,'selector',selname);

sanity_check(pat,regs,sel);

TRs_to_use = find(sel==1);

% Note: don't forget to exclude rest timepoints, unless your
% function definitely requires them

pat   = pat(:,TRs_to_use);
regs = regs(:,TRs_to_use);

% Do all the hard work inside STATMAP_TEMPLATE_LOGIC
p = statmap_template_logic(pat,regs,extra_arg);

% Now create a new pattern object to house the statmap with the p
% values in it
subj = init_object(subj,'pattern',new_map_patname);
subj = set_mat(subj,'pattern',new_map_patname,p);

% Every pattern needs to know which mask it is masked by
masked_by = get_objfield(subj,'pattern',data_patname,'masked_by');
subj = set_objfield(subj,'pattern',new_map_patname,'masked_by',masked_by);

hist = sprintf('Created by statmap_template',data_patname);
subj = add_history(subj,'pattern',new_map_patname,hist);

created.function = 'statmap_template';
created.data_patname = data_patname;
created.regsname = regsname;
created.selname = selname;
subj = add_created(subj,'pattern',new_map_patname,created);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [p] = statmap_template_logic(pat,regs,args)

% This is where the logic for your custom statmap should go



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [] = sanity_check(pat,regs,sel,args)

% This is where you should check that your assumptions are met
