function [errmsgs warnmsgs] = unit_convert_maskpat_idx()

% Tests CONVERT_MASK_TO_PAT_IDX and CONVERT_PAT_TO_MASK_IDX
% 
% [ERRMSGS WARNMSGS] = UNIT_CONVERT_MASKPAT_IDX()
%
% Only a single, rudimentary confirmation that the one
% undoes the other.


errmsgs = {};
warnmsgs = {};

mask = round(rand(10,10,10));
keep_idx = find(mask);
nActiveVox = length(keep_idx);

pat_idx = convert_mask_to_pat_idx(mask,keep_idx);
mask_idx = convert_pat_to_mask_idx(mask,pat_idx);

if ~isequal(mask_idx,keep_idx)
  errmsgs{end+1} = 'Problem converting from mask to pat to mask';
end



