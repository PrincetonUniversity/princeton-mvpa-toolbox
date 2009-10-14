function [vol] = volumize_pattern(pat,mask,varargin)

% Turns an nVox x nTimepoints pattern into a 4D XYZT matrix
%
% [VOL] = VOLUMIZE_PATTERN(PAT,MASK, ...)
%
% Returns a 4D XYZT matrix containing the pattern
% data. Positions excluded from the mask are set to zero.
%
% The MASK must include the same number of dimensions as
% rows in your PAT.
%
% MARK_EXCL_AS (optional, default = NaN). By default, all
% voxels excluded by the original mask will be set to NaN,
% so that they can be easily differentiated. Cannot be set
% to 1, otherwise there would be no way to tell the excluded
% from included.
%
% TIMEPOINT_IDX (optional, default = []). By default, if
% you feed in a pattern with t timepoints, your 4D
% matrix's 4th dimension will be t in length. If
% TIMEPOINT_IDX contains a vector of timepoint indices,
% only these timepoints will be included in the 4D
% matrix.

% License:
%=====================================================================
%
% This is part of the Princeton MVPA toolbox, released under
% the GPL. See http://www.csbmb.princeton.edu/mvpa for more
% information.
% 
% The Princeton MVPA toolbox is available free and
% unsupported to those who might find it useful. We do not
% take any responsibility whatsoever for any problems that
% you have related to the use of the MVPA toolbox.
%
% ======================================================================

defaults.mark_excl_as = NaN;
defaults.timepoint_idx = [];
args = propval(varargin,defaults);

sanity_check(args);

incl_m_idx = find(mask);
nVox = length(incl_m_idx);

if nVox ~= size(pat,1)
  error('Your mask and pattern have different numbers of voxels');
end

nTimepoints = size(pat,2);

% swap the mask zeros for something else, e.g. NaN. This is
% so that you can tell the excluded voxels apart from any
% actual pattern values that are 0.
mask(find(~mask)) = args.mark_excl_as;

vol = repmat(mask,[1 1 1 nTimepoints]);

vol(find(vol==1)) = pat;

confirm_number_of_voxels_included(pat,vol,args);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [] = sanity_check(args);

if ~isempty(args.timepoint_idx)
  pat = pat(:,args.timepoint_idx);
end

if numel(args.mark_excl_as)~=1
  error('Need to set a single mark for excluded voxels');
end

if args.mark_excl_as == 1
  error('Cannot mark excluded voxels with 1s');
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [] = confirm_number_of_voxels_included(pat,vol,args)

% error checking
if isnan(args.mark_excl_as)
  nIncl = length(find(~isnan(vol)));
else
  nIncl = length(find(vol));
end
if nIncl ~= numel(pat)
  % This could happen if you set your
  % MARK_EXCL_AS value to be the same as a value also 
  % found in your pattern
  warning('The number of voxels included in the mask isn''t right');
end
