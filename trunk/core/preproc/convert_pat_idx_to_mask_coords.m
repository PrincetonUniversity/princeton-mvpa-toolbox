function [mask_coords] = convert_pat_idx_to_mask_coords(mask,pat_idx)

% [MASK_COORDS] = CONVERT_PAT_IDX_TO_MASK_COORDS(MASK,PAT_IDX)
%
% Inverse operation of CONVERT_MASK_COORDS_TO_PAT_IDX.


if ~exist('pat_idx','var')
  incl_m_idx = find(mask);
  pat_idx = 1:length(incl_m_idx);
end

mask_idx = convert_pat_to_mask_idx(mask,pat_idx);

[x y z] = ind2sub(size(mask),mask_idx);
mask_coords = [x y z];

