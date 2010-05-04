function [mask_coords] = convert_mask_idx_to_mask_coords(mask, mask_idx)

% MASK_IDX is a vector of indices into MASK. Returns coordinates for
% each of these indices.
%
% See CONVERT_MASK_COORDS_TO_PAT_IDX for a description of the form
% that MASK and COORDS must take.

[x y z] = ind2sub(size(mask), mask_idx);
mask_coords = [x y z];
