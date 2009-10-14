function [pat] = get_full_pattern(subj, patname, varargin)
% Retrieves a pattern in volume or padded matrix form.
%
% This is useful for saving patterns to AFNI or for computing
% statistics for patterns in +tlrc space, where voxels have a 1:1
% correspondence.
% 
% Usage:
%
% [PAT] = GET_FULL_PATTERN(SUBJ, PATNAME, ...)
%
% Output Arguments:
% 
%   PAT - 2D pattern matrix or 4D volume (see FORMAT.)
%
% Input Arguments:
%
%   SUBJ - Subj structure (obviously.)
%
%   PATNAME - Pattern to be retrieved.
%
% Optional Arguments:
%
%   FORMAT - Either 'matrix' (Default) or 'vol'. If 'matrix',
%     returns a VxT matrix where V is the number of voxels in the
%     entire associated volume, and T is the number of
%     timepoints. If 'vol', returns the same in 4D IxJxKxT format.
%
%   PADDING - The value to use for timecourses from masked voxels
%     in the original pattern PATNAME. (Default: 0)
%
%   SINGLE - Returns the object with single precision.
%

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

defaults.format = 'matrix';
defaults.padding = 0;
defaults.single = false;

args = propval(varargin, defaults);

if args.single
  args.padding = single(args.padding);
end

smallpat = get_mat(subj, 'pattern', patname);
refvol = get_ref_vol(subj, patname);

if strcmp(args.format, 'matrix')
  pat = repmat(single(args.padding), [numel(refvol), cols(smallpat)]);

  for i = 1:cols(smallpat)
    vol = refvol;
    vol(find(vol)) = smallpat(:,i);
    
    pat(:,i) = vol(:);
  end
  
elseif strcmp(args.format, 'vol')

  % Create the 4D time matrix
  pat = repmat(args.padding, [size(refvol) cols(smallpat)]);
  midx = find(refvol(:));

  [i,j,k] = ind2sub(size(refvol), midx);  
    
  % Figure out the time indices of these active voxels
  
  % Get i,j,k of existing voxels 
  for t = 1:cols(smallpat)    
  
    tidx = sub2ind(size(pat), i,j,k,repmat(t,numel(i),1));    
    pat(tidx) = smallpat(:,t); 
    
  end  
  
else
  error('Unrecognized format ''%s''', args.format);
end





