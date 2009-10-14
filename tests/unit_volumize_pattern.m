function [errmsgs warnmsgs] = unit_volumize_pattern()

% Tests VOLUMIZE_PATTERN
%
% [ERRMSGS WARNMSGS] = UNIT_VOLUMIZE_PATTERN()
%
% Assumes you've run the confirm_number_of_voxels
% function built in to volumize_pattern


errmsgs = {};
warnmsgs = {};

nVox = 10;
nTimepoints = 20;
pat = rand(nVox,nTimepoints);

vol_length = 10;
mask = zeros([vol_length vol_length vol_length]);

% just need to make a random nVox selection of these
% 1s...
keep_idx = shuffle(1:numel(mask));
mask(keep_idx(1:nVox)) = 1;

vol = volumize_pattern(pat,mask);

vol1 = vol(:,:,:,1);
vol1 = vol1(find(~isnan(vol1)));
if ~isequal(vol1,pat(:,1))
  errmsgs{end+1} = 'The first timepoint of vol isn''t right';
end




