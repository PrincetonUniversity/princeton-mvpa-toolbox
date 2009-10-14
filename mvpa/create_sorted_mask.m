function [subj] = create_sorted_mask(subj,map_patin,new_maskname,nkeep,varargin)

% Create a boolean mask including only the top/bottom NKEEP voxels
%
% SUBJ = CREATE_SORTED_MASK(SUBJ,MAP_PATIN,NEW_MASKNAME,NKEEP,...)
%
% Adds the following objects:
% - mask object OR mask group (if PATGROUP == true)
%
% Takes the MAP_PATIN statmap pattern (or group of statmaps) and finds
% the top NKEEP values (or bottom if DESCENDING == false). Creates a
% boolean mask with 1s for the locations that meet the threshold
% criterion
%
% DESCENDING (optional, default = true). By default, sorts the
% voxels in descending order, and chooses the first NKEEP. To sort in
% ascending order, set to false.

% This is part of the Princeton MVPA toolbox, released under the
% GPL. See http://www.csbmb.princeton.edu/mvpa for more
% information.


defaults.descending = true;
args = propval(varargin,defaults);

if ~isnumeric(nkeep)
  error('Numerical value expected for N');
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

  if size(pat,2)~=1
    error('Can''t create a mask from a pat with a time dimension');
  end
  
  % Get Pattern Number, Mask
  mask_for_pat = get_objfield(subj,'pattern',cur_map_patname,'masked_by');
  oldmask = get_mat(subj,'mask',mask_for_pat);

  % Create a new mask with new cur_maskname
  subj = duplicate_object(subj,'mask',mask_for_pat,cur_maskname);

  % Identify suprathreshold voxels
  % MASKVEC is going to be a boolean vector
  maskvec = zeros(size(pat));
  if args.descending
    [vals idx] = sort(pat,1,'descend');
  else
    [vals idx] = sort(pat,1,'ascend');
  end
  clear val
    
  maskvec(idx(1:nkeep)) = 1;

  % OLDMASK is a mask volume. We want NEWMAT to be in the same
  % space
  newmat = zeros(size(oldmask));
  
  % Mark 1s in the right places in the NEWMAT boolean volume for each
  % of the suprathreshold voxels active in the boolean MASKVEC vector
  newmat(find(oldmask)) = maskvec;

  % Save to the mask
  subj = set_objfield(subj,'mask',cur_maskname,'nkeep',nkeep,'ignore_absence',true);
  if isgroup
    subj = set_objfield(subj,'mask',cur_maskname,'group_name',new_maskname);
  end
  subj = set_mat(subj,'mask',cur_maskname,newmat);

  % Update the header
  created.function = 'create_thresh_mask';
  created.dbstack = dbstack;
  created.map_patname = cur_map_patname;
  created.args = args;
  subj = add_created(subj,'mask',cur_maskname,created);
  
end % for m

% disp(hist)
