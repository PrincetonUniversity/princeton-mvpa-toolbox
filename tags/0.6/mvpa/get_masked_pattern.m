function [masked_pat] = get_masked_pattern(subj,patname,maskname)

% Returns the pattern's voxels allowed by the mask
%
% [MASKED_PAT] = GET_MASKED_PATTERN(SUBJ,PATNAME,MASKNAME)
%
% Calls get_pattern to retrieve the PATNAME mat, and then applies the
% boolean MASKNAME volume to whittle down the voxels, and returns this
% smaller patterns mat. See the section, 'Figuring out which voxel
% is which, and where' in the manual for more information.
%
% Note: this returns a pattern matrix (included_voxels x
% timepoints). It's up to the user to init this as a proper object
% if so desired
%
% Will not warn you if no voxels are allowed through. Up to the
% user to check for this

% This is part of the Princeton MVPA toolbox, released under the
% GPL. See http://www.csbmb.princeton.edu/mvpa for more
% information.


pat = get_mat(subj,'pattern',patname);

% Get the reference space volumes of the new mask and the pattern's
% own mask. They should be the same dimensions
childvol = get_mat(subj,'mask',maskname);
parentvol = get_ref_vol(subj,patname);

% xxx Allow for 2D masks???
if ndims(parentvol) ~= 3
  error('Your parent vol isn''t 3 dimensions');
end

if ~compare_size(childvol,parentvol)
  error('Your parent and child mask volumes are different sizes');
end

% both these sets of indices are now relative to the reference volume
% space
childidx = find(childvol);
parentidx = find(parentvol);

[intersectidx ia ib] = intersect(parentidx,childidx);

idx_of_child_items_contained_in_parent = ia;

if length(intersectidx) ~= length(childidx)
  warning('Some voxels present in the mask were not present in the pattern');
end

masked_pat = pat(idx_of_child_items_contained_in_parent,:);
