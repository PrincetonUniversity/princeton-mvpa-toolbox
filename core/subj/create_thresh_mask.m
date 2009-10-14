function [subj] = create_thresh_mask(subj,map_patin,new_maskname,thresh,varargin)

% Create a boolean mask by thresholding a statmap
%
% SUBJ = CREATE_THRESH_MASK(SUBJ,MAP_PATIN,NEW_MASKNAME,THRESH,VARARGIN)
%
% Adds the following objects:
% - mask object OR mask group (if PATGROUP == true)
%
% Takes the MAP_PATIN statmap pattern (or group of statmaps) and finds
% all the values that are less than (unless GREATER_THAN == true) the
% THRESH criterion value. Creates a boolean mask with 1s for the
% locations that meet the threshold criterion
%
% GREATER_THAN (optional, default false) is a Greater Than/Less Than
% Toggle. Default = false (less-than), set to TRUE for greater than
%
% ABS_FIRST (optional, default = false). If true, takes
% the abs() of all the map values before thresholding.

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


defaults.greater_than = false;
defaults.abs_first = false;
args = propval(varargin,defaults);

if ~isnumeric(thresh)
  error('Numerical value expected for threshold');
end

[map_patnames isgroup] = find_group_single(subj,'pattern',map_patin);
if isgroup
  hist_objtype = 'Mask group';
else
  hist_objtype = 'Mask object';
end

for m=1:length(map_patnames)
  cur_map_patname = map_patnames{m};
  
  if isgroup
    cur_maskname = sprintf('%s_%i',new_maskname,m);
  else
    cur_maskname = new_maskname;
  end
  
  pat = get_mat(subj,'pattern',cur_map_patname);

  if size(pat,2)>1
    error('Your pattern has to be a statmap vector, not a matrix');
  end
  
  if args.abs_first
    pat = abs(pat);
  end
  
  % Get Pattern Number, Mask
  mask_for_pat = get_objfield(subj,'pattern',cur_map_patname,'masked_by');
  oldmask = get_mat(subj,'mask',mask_for_pat);

  % Create a new mask with new cur_maskname
  subj = duplicate_object(subj,'mask',mask_for_pat,cur_maskname);

  % Identify suprathreshold voxels
  % MASKVEC is going to be a boolean vector
  maskvec = zeros(size(pat));
  if args.greater_than
    % Couldn't decide whether this should be greater-than
    % or greater-than-or-equal to. Opted for greater-than
    % so that exactly on-threshold values don't get
    % included in both cases. This may not matter much anyway
    maskvec(find(pat(:,1) > thresh)) = 1;
  else
    maskvec(find(pat(:,1) <= thresh)) = 1;
  end

  % OLDMASK is a mask volume. We want NEWMAT to be in the same
  % space
  newmat = zeros(size(oldmask));
  
  % Mark 1s in the right places in the NEWMAT boolean volume for each
  % of the suprathreshold voxels active in the boolean MASKVEC vector
  newmat(find(oldmask)) = maskvec;

  % Save to the mask
  subj = set_objfield(subj,'mask',cur_maskname,'thresh',thresh);
  if isgroup
    subj = set_objfield(subj,'mask',cur_maskname,'group_name',new_maskname);
  end
  subj = set_mat(subj,'mask',cur_maskname,newmat);

  % Update the header
  hist = sprintf('%s, thresh=%.4f, nVox=%i, created by create_thresh_mask', ...
		 hist_objtype,thresh,length(find(maskvec)));
  subj = add_history(subj,'mask',cur_maskname,hist);

  created.function = 'create_thresh_mask';
  created.map_patname = cur_map_patname;
  created.args = args;
  subj = add_created(subj,'mask',cur_maskname,created);
  
end % for m

% disp(hist)
