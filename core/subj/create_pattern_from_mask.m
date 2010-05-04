function [subj] = create_pattern_from_mask(subj,old_patname,maskin,new_patname,varargin)

% Creates a new pattern by masking an old one
%
% SUBJ = CREATE_PATTERN_FROM_MASK(SUBJ,OLD_PATNAME,MASKIN,NEW_PATNAME,...)
%
% Creates a new pattern called NEW_PATNAME from an
% existing one called OLD_PATNAME, including only the voxels
% allowed through by MASKIN.
%
% MASKIN is the name of a mask object or group
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


defaults.ignore_empty = false;
args = propval(varargin,defaults);

[masknames isgroup] = find_group_single(subj,'mask',maskin);

for i=1:length(masknames)

  cur_maskname = masknames{i};
  
  if isgroup
    cur_new_patname = [new_patname '_' num2str(i)];
  else
    cur_new_patname = new_patname;
  end
  
  % Do the hard work
  masked_pat = get_masked_pattern(subj,old_patname,cur_maskname);

  % Warn and return if no voxels are allowed through (unless IGNORE_EMPTY)
  if isempty(masked_pat) && ~args.ignore_empty
    warn_str = sprintf('No features from %s were allowed through by %s - not creating %s', ...
	  	     old_patname,cur_maskname,cur_new_patname);
    warning(warn_str);
    return
  end

  % Create the new object
  subj = duplicate_object(subj,'pattern',old_patname,cur_new_patname);

  % Now replace the new pattern's mat with the masked_pat
  subj = set_mat(     subj,'pattern',cur_new_patname,masked_pat,'ignore_diff_size',true);
  subj = set_objfield(subj,'pattern',cur_new_patname,'masked_by',cur_maskname);

  if isgroup
    subj = set_objfield(subj,'pattern',cur_new_patname, 'group_name',new_patname);
  else
    subj = set_objfield(subj,'pattern',cur_new_patname, 'group_name','');
  end
  
  created.function = 'create_pattern_from_mask';
  subj = add_created(subj,'pattern',cur_new_patname,created);

  hist = sprintf('Pattern ''%s'' created by %s', cur_new_patname,created.function);
  subj = add_history(subj,'pattern',cur_new_patname,hist,true);
end
