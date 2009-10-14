function [subj] = statmap_template(subj,data_patname,regsname,selname,new_map_patname,extra_arg)
                  %todo title
		  
% This is the sample/template statmap generation function
% %todo synopsis
%
% [SUBJ] = STATMAP_TEMPLATE(SUBJ,DATA_PATNAME,REGSNAME,SELNAME,NEW_MAP_PATNAME,EXTRA_ARG)
%          %todo function header
%
% Adds the following objects:
% - statmap pattern object
%
% Updates the subject structure by creating a new pattern,
% NEW_MAP_PATNAME, that contains a vector of P-values (for example)
%
% See STATMAP_ANOVA for a real example script %todo
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
% EXTRA_ARG (optional, default = []). This could do anything, and
% the default could be anything. STATMAP_ANOVA.M ignores this, but
% other statmap functions might need it. %todo
%
% See the section on creating your own statmap in the manual %todo

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


defaults.extra_arg = [];
% todo default arguments
args = propval(defaults,extra_arg);

pat  = get_mat(subj,'pattern',data_patname);
regs = get_mat(subj,'regressors',regsname);
sel  = get_mat(subj,'selector',selname);

sanity_check(pat,regs,sel,args);

TRs_to_use = find(sel==1);

% Note: don't forget to exclude rest timepoints, unless your
% function definitely requires them

pat   = pat(:,TRs_to_use);
regs = regs(:,TRs_to_use);

% Do all the hard work inside STATMAP_TEMPLATE_LOGIC
map = statmap_template_logic(pat,regs,args);
%todo main function

% Every pattern needs to know which mask it is masked by,
% so find that out
masked_by =
% get_objfield(subj,'pattern',data_patname,'masked_by'); Now
% create a new pattern object to house the statmap with the
% map values in it
subj = initset_object(subj,'pattern',new_map_patname,map, ...
                      'masked_by',masked_by);

hist = sprintf('Created by %s',mfilename());
subj = add_history(subj,'pattern',new_map_patname,hist);

created.function = mfilename();
created.data_patname = data_patname;
created.regsname = regsname;
created.selname = selname;
created.new_map_patname = new_map_patname;
created.args = args;
subj = add_created(subj,'pattern',new_map_patname,created);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [p] = statmap_template_logic(pat,regs,args)

% This is where the logic for your custom statmap should go
% todo


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [] = sanity_check(pat,regs,sel,args)

% This is where you should check that your assumptions are met
% todo
