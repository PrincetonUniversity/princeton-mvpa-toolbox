function [subj] = remove_timepoints(subj,objtype,objin,actives_selname,varargin)

% Remove timepoints from an object or group
%
% [SUBJ] = remove_timepoints(SUBJ,OBJTYPE,OBJIN,ACTIVES_SELNAME,...)
%
% Feed in a selector ACTIVES_SELNAME with 1s for the timepoints that
% you want to keep, and an object/group OBJIN name from which you want to
% prune the timepoints. This will create new versions of them
% called NEW_OBJNAME
%
% Adds the following objects:
% - object/group of type OBJTYPE called NEW_OBJNAME
%
% NEW_OBJNAME (optional, default = 'OBJIN_rt'). Each new object that
% gets created will have this suffix appended
%
% REMOVE_OLD_MAT (optional, default = false). Set to true to remove
% the mat from the old object, if you're sure you don't want it.

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


defaults.new_objname = [];
defaults.remove_old_mat = false;
args = propval(varargin,defaults);

if isempty(args.new_objname)
  new_stem = sprintf('%s_rt',objin);
else
  new_stem = args.new_objname;
end

[old_objnames isgroup] = find_group_single(subj,objtype,objin);
if isgroup
  group_name = new_stem;
  for m=1:length(old_objnames)
    new_objnames{m} = sprintf('%s_rt',old_objnames{m});
  end
else
  group_name = '';
  new_objnames{1} = new_stem;
end

% You probably want to feed in a boolean selector with 1s for TRs you
% want to keep and 0s for TRs you want to throw away.
sel = get_mat(subj,'selector',actives_selname);
if length(unique(sel))~=2
  error('Your actives_sel isn''t boolean');
end
TRs_to_keep = find(sel);

for m=1:length(old_objnames)
  
  if ~exist_object(subj,objtype,old_objnames{m})
    error( sprintf('No %s %s exists to remove timepoints from', ...
		   old_objnames{m},objtype) );
  end
  
  if strcmp(objtype,'selector') && strcmp(old_objnames{m},actives_selname)
    error('You probably don''t mean to remove the timepoints from the actives_sel');
  end

  [subj cur_mat] = duplicate_object(subj,objtype,old_objnames{m},new_objnames{m}, ...
				    'include_unknown_fields',true);
  cur_mat = cur_mat(:,TRs_to_keep);
  
  subj = set_mat(subj,objtype,new_objnames{m},cur_mat,'ignore_diff_size',true);
 
  subj = set_objfield(subj,objtype,new_objnames{m},'group_name',group_name);

  created.function = mfilename;
  created.actives_selname = actives_selname;
  subj = add_created(subj,objtype,new_objnames{m},created);

  if args.remove_old_mat
    subj = remove_mat(subj,objtype,old_objnames{m});
  end
  
end % m length(objnames)




