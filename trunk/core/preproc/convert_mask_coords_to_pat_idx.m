function [pat_idx] = convert_mask_coords_to_pat_idx(mask,coords)

% [PAT_IDX] = CONVERT_MASK_COORDS_TO_PAT_IDX(MASK,COORDS)
%
% MASK = X x Y x Z boolean matrix, i.e. a normal mask matrix
%
% COORDS (optional) = nVox x 3 matrix of x,y,z
% coordinates. By default, assumes you want all the active
% voxels in the mask. Otherwise, I think you can use COORDS
% to specify coordinates for a subset of the voxels from the
% mask that you want.
%
% Returns PAT_IDX, a vector of indices corresponding to the
% voxels specified by COORDS. These indices are for the
% voxel-rows in a (vox x time) pattern. Each row in COORDS
% corresponds to a row in the pattern. The pattern must have
% MASK as its mask. Relies on CONVERT_MASK_TO_PAT_IDX for this.
%
% N.B. these comments were written a long time after the
% function itself, so please write to
% mvpa-toolbox@googlegroups.com if you think they're
% misleading.


if ~exist('coords','var')
  [x y z] = ind2sub(size(mask),find(mask));
  coords(:,1) = x;
  coords(:,2) = y;
  coords(:,3) = z;
end

if size(coords,2)~=3
  error('Coords must be in nVox x 3 format');
end

mask_idx = sub2ind(size(mask),coords(:,1),coords(:,2),coords(:,3));
pat_idx = convert_mask_to_pat_idx(mask,mask_idx);

