function [subj] = remove_timepoints(subj,objtype,old_objname,actives_selname,varargin)

% Remove timepoints from an object or group
%
% [SUBJ] = remove_timepoints(SUBJ,OBJTYPE,OLD_OBJNAME,ACTIVES_SELNAME,...)
%
% Feed in a selector ACTIVES_SELNAME with 1s for the timepoints that
% you want to keep, and an object/group OLD_OBJNAME name from which you want to
% prune the timepoints. This will create new versions of them
% called NEW_OBJNAME
%
% Adds the following objects:
% - object/group of type OBJTYPE called NEW_OBJNAME
%
% NEW_OBJNAME (optional, default = 'OLD_OBJNAME_lesstime'). Each new object that
% gets created will have this suffix appended
%
% REMOVE_OLD_MAT (optional, default = false). Set to true to remove
% the mat from the old object, if you're sure you don't want it.


defaults.new_objname = [];
defaults.remove_old_mat = false;
args = propval(varargin,defaults);

[old_objnames isgroup] = find_group_single(subj,objtype,old_objname);
if isgroup
  group_name = old_objname;
else
  group_name = '';
end

% You probably want to feed in a boolean selector with 1s for TRs you
% want to keep and 0s for TRs you want to throw away.
sel = get_mat(subj,'selector',actives_selname);
if length(unique(sel))~=2
  error('Your actives_sel isn''t boolean');
end
TRs_to_keep = find(sel);

for m=1:length(old_objnames)
  
  cur_objname = old_objnames{m};

  if isempty(args.new_objname)
    args.new_objname = sprintf('%s_lesstime',cur_objname);
  end
  
  if ~exist_object(subj,objtype,cur_objname)
    error( sprintf('No %s %s exists to remove timepoints from', ...
		   cur_objname,objtype) );
  end
  
  if strcmp(objtype,'selector') && strcmp(cur_objname,actives_selname)
    error('You probably don''t mean to remove the timepoints from the actives_sel');
  end

  [subj cur_mat] = duplicate_object(subj,objtype,cur_objname,args.new_objname, ...
				    'include_unknown_fields',true);
  cur_mat = cur_mat(:,TRs_to_keep);
  
  subj = set_mat(subj,objtype,args.new_objname,cur_mat,'ignore_diff_size',true);
 
  subj = set_objfield(subj,objtype,args.new_objname,'group_name',group_name);

  created.function = mfilename;
  created.actives_selname = actives_selname;
  subj = add_created(subj,objtype,args.new_objname,created);

  if args.remove_old_mat
    subj = remove_mat(subj,objtype,old_objname);
  end
  
end % m length(objnames)




