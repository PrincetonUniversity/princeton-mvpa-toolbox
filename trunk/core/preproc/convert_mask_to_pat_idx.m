function [pat_idx] = convert_mask_to_pat_idx(mask,mask_idx)

% [PAT_IDX] = CONVERT_MASK_TO_PAT_IDX(MASK,MASK_IDX)
%
% MASK_IDX = a vector of indices into 3D boolean matrix
% mask. [I don't remember how it works if MASK_IDX only
% indexes into a subset of the active voxels in mask.]
%
% Returns PAT_IDX, a vector of indices corresponding to the
% voxels specified by MASK_IDX. The PAT_IDX indices are for
% the voxel-rows in a (vox x time) pattern. Each index value
% in MASK_IDX corresponds to a row in the pattern. The
% pattern must have MASK as its mask.
%
% See also: CONVERT_MASK_COORDS_TO_PAT_IDX


% this code is ripped straight out of adj_cuboid. i was
% trying to abstract it out, so there'd be one handy
% function to call
%
% this might not be any use, because you're probably
% going to want to use it inside a voxel loop, each time
% on a different adjacency list (MASK_IDX), so you don't
% want to run the first two lines of this function each
% time you do that


if ~exist('mask_idx','var')
  mask_idx = find(mask);
end

mask_to_pat_idx = NaN(size(mask));
nVox = length(find(mask));
mask_to_pat_idx(find(mask)) = 1:nVox;
pat_idx = sort(mask_to_pat_idx(mask_idx));

if length(find(isnan(pat_idx)))
  error('You''re trying to get the pattern indices of voxels excluded from the mask');
end
