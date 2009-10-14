function [mask_idx] = convert_pat_to_mask_idx(mask,pat_idx)

% [MASK_IDX] = CONVERT_PAT_TO_MASK_IDX(MASK,PAT_IDX)
%
% Inverse operation of CONVERT_MASK_TO_PAT_IDX


keep_idx = find(mask);

if ~exist('pat_idx','var')
  pat_idx = 1:length(keep_idx);
end

pat_to_mask_idx = zeros(size(mask));
pat_to_mask_idx(keep_idx(pat_idx)) = 1;

mask_idx = find(pat_to_mask_idx);
