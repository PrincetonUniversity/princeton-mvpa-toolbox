function [subj] = blur_pattern(subj, patname, fwhm, varargin)
% BLUR_PATTERN - Spatially blurs a pattern.
%
% Usage:
%
%  [SUBJ] = BLUR_PATTERN(SUBJ, PATNAME, FWHM, ...)
%
% Spatially blurs a pattern by 3D convolution with a Gaussian
% kernel with Full-Width Half Max of FWHM voxels. FWHM is
% not restricted to integers. Each timepoint of the pattern is
% blurred separately.
%
% Optional Arguments:
%
%  'single' - Whether or not to use single precision to save
%             memory.  Default False.
%
%  'n' - The size of the gaussian filter in voxels. (Default: ceil(FHWM)) 
%
%  'new_patname' - The name of the new blurred pattern. 
%                  (Default: patname_sm<FWHM>)

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

defaults.single = false; %defautl changed 2-8-2011 GTM, responce to bug report by Zhen James Xiang on 1-25-2011
defaults.n = ceil(fwhm);
defaults.new_patname = sprintf('%s_sm%g', patname, fwhm);

args = propval(varargin, defaults);

% Retrieve 4D pattern
vol = get_full_pattern(subj, patname, 'format', 'vol', 'single', args.single);

% Get mask info to recreat pattern
maskname = get_objfield(subj, 'pattern', patname, 'masked_by');
mask = get_mat(subj, 'mask', maskname);

midx = find(mask);

% Make the filter
filt = normfilt(args.n, fwhm, 3);

% Preallocate new matrix
pat = single(zeros(count(mask), size(vol,4)));

dispf('Smoothing timepoints:');
for t = 1:size(vol,4)
  fprintf('%d..', t);
  v = single(squeeze(vol(:,:,:,t)));

  % Do the 3d convolution
  v = convn(v, filt, 'same');
  
  % retrieve smoothed values
  pat(:,t) = v(midx);
end
dispf('completed.');

if args.single
  pat = single(pat);
else
    pat = double(pat);
end

% Insert the new pattern
subj = initset_object(subj, 'pattern', args.new_patname, ...
                      pat, 'masked_by', maskname);