function [subj] = create_thresh_mask(subj,map_patname,new_maskname,thresh,varargin)

% Create a boolean mask by thresholding a statmap
%
% SUBJ = CREATE_THRESH_MASK(SUBJ,MAP_PATNAME,NEW_MASKNAME,THRESH,VARARGIN)
%
% Adds the following objects:
% - mask object OR mask group (if PATGROUP == true)
%
% Takes the MAP_PATNAME statmap pattern (or group of statmaps if PATGROUP
% = true), and finds all the values that are less than (unless
% GREATER_THAN == true) the THRESH criterion value. Creates a
% boolean mask with 1s for the locations that meet the threshold criterion
%
% GREATER_THAN (optional, default false) is a Greater Than/Less Than
% Toggle. Default = false (less-than), set to TRUE for greater than
%
% PATGROUP (optional, default false) - if true, will treat MAP_PATNAME as
% a pattern group name, and will create a group of masks by
% individually thresholding all the members of the pattern
% group. Useful for trying multiple thresholds from NOPEEK_FEATURE_SELECT


defaults.greater_than = false;
defaults.patgroup = false;
args = propval(varargin,defaults);

if ~isnumeric(thresh)
  error('Numerical value expected for threshold');
end

% If PATGROUP = true, then instead of dealing with a single pattern
% called MAP_PATNAME, we're going to be working on multiple patterns,
% and creating multiple masks
if args.patgroup
  map_patnames = find_group(subj,'pattern',map_patname);
  for m=1:length(map_patnames)
    masknames{m} = sprintf('%s_%i',new_maskname,m);
  end
  maskgroupname = new_maskname;
  hist_objtype = 'Mask group';
% And if PATGROUP = false, then we're still going to use the same
% variables as above, but they're only going to contain one value
% each, and no groupname
else
  map_patnames{1} = map_patname;
  masknames{1} = new_maskname;
  maskgroupname = '';
  hist_objtype = 'Mask';
end

for m=1:length(map_patnames)
  cur_map_patname = map_patnames{m};
  cur_maskname = masknames{m};
  
  pat = get_mat(subj,'pattern',cur_map_patname);

  % Get Pattern Number, Mask
  mask_for_pat = get_objfield(subj,'pattern',cur_map_patname,'masked_by');
  oldmask = get_mat(subj,'mask',mask_for_pat);

  % Create a new mask with new cur_maskname
  subj = duplicate_object(subj,'mask',mask_for_pat,cur_maskname);

  % Identify suprathreshold voxels
  % MASKVEC is going to be a boolean vector
  maskvec = zeros(size(pat));
  if args.greater_than
    maskvec(find(pat(:) > thresh)) = 1;
  else
    maskvec(find(pat(:) < thresh)) = 1;
  end

  % OLDMASK is a mask volume. We want NEWMAT to be in the same
  % space
  newmat = zeros(size(oldmask));
  
  % Mark 1s in the right places in the NEWMAT boolean volume for each
  % of the suprathreshold voxels active in the boolean MASKVEC vector
  newmat(find(oldmask)) = maskvec;

  % Save to the mask
  subj = set_objfield(subj,'mask',cur_maskname,'thresh',thresh);
  subj = set_objfield(subj,'mask',cur_maskname,'group_name',maskgroupname);
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
