function [subj] = create_pattern_from_mask(subj,old_patname,maskname,new_patname,varargin)

% Creates a new pattern by masking an old one
%
% SUBJ = CREATE_PATTERN_FROM_MASK(SUBJ,OLD_PATNAME,MASKNAME,NEW_PATNAME,...)
%
% Creates a new pattern called NEW_PATNAME from an
% existing one called OLD_PATNAME, including only the voxels
% allowed through by MASKNAME
% 
% Adds the following objects:
% - pattern (unless IGNORE_EMPTY condition)
%
% If the intersection is empty, it returns a warning and does not
% create a new patterns cell, unless IGNORE_EMPTY is true
%
% IGNORE_EMPTY (optional, default = false). By default, this exits
% without creating a pattern if no features are allowed through. If
% set to true, this will create the pattern anyway without issuing
% a warning


defaults.ignore_empty = false;
args = propval(varargin,defaults);

% Do the hard work
masked_pat = get_masked_pattern(subj,old_patname,maskname);

% Warn and return if no voxels are allowed through (unless IGNORE_EMPTY)
if isempty(masked_pat) & ~args.ignore_empty
  warn_str = sprintf('No features from %s were allowed through by %s - not creating %s', ...
		     old_patname,maskname,new_patname);
  warning(warn_str);
  return
end

% Create the new object
subj = duplicate_object(subj,'pattern',old_patname,new_patname);

% Now replace the new pattern's mat with the masked_pat
subj = set_mat(subj,'pattern',new_patname,masked_pat,'ignore_diff_size',true);
subj = set_objfield(subj,'pattern',new_patname,'masked_by',maskname);

created.function = 'create_pattern_from_mask';
subj = add_created(subj,'pattern',new_patname,created);

hist = sprintf('Pattern ''%s'' created by %s',...
	       new_patname,created.function);
subj = add_history(subj,'pattern',new_patname,hist,true);
