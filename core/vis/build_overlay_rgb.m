function [im im3d args] = build_overlay_rgb(anat_vol, anat_rgb, over_vol, over_rgb, varargin)

% BUILD_OVERLAY_RGB - Assembles the overlay RGB image from
% anatomical and overlay data.
%
% Usage:
%
%  [IM IM3D ARGS] = BUILD_OVERLAY_RGB(ANAT_VOL, ANAT_RGB, OVER_VOL, OVER_RGB, ...)
%
%  BUILD_OVERLAY_RGB combines anatomical and overlay RGB data and
%  builds a montage image of the result. It is best to use
%  VIEW_PATTERN_OVERLAY; don't call this function directly.
% 
% Outputs:
%
%  IM - An RGB montage image of the brain slices composited with
%    overlay.
%
%  IM3D - An RGB image where the R,G, and B channels of each pixel
%    indicate the I,J,K coordinates in the 3D volume that was passed in.
%
% Required Parameters:
%
%   ANAT_VOL - 3D Binary mask volume for the anatomical data.
%   
%   ANAT_RGB - RGB channel data for points in ANAT_VOL.
%
%   OVER_VOL - 3D Binary mask volume for the overlay data.
%
%   OVER_RGB - RGB channel data for points in OVER_VOL.
%
% Optional Parameters:
%
%   SHIFTDIM - Whether or not to use SHIFTDIM to overlay along
%     dimensions other than the default.
%
%   AUTOSLICE - Automatically removes slices that don't have any
%     voxels from OVER_VOL in them, before plotting.
%
%   AUTOSLICE_THRESH - The minimum number of voxels to be included
%     by AUTOSLICE.
%
%   MAXSLICES - The maximum number of slices to display (default: 64)
%
%   SLICES - The slice indices to display.
%   
%   NROWS - The number of rows to use in the display grid. If NCOLS is
%     not set, then NCOLS will scale automatically to fit the slices.
%   
%   NCOLS - The number of columns to use in the display grid. If NROWS is
%     not set, then NROWS will scale automatically to fit the slices.
% 
%   BGCOLOR - The background color (RBG) to use. Default: [0 0 0] (black).
%
%   CROP - A rectangle indicating the indices of each slice to KEEP,
%     throwing out the rest before compositing.
% 
%   NSLICE - What interval to sample slices at (this will be
%     set by default to avoid having more than MAXSLICES slices.)

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


defaults.shiftdim = 0;

defaults.slices = [];
defaults.nslice = 1;
defaults.nrows = [];
defaults.ncols = [];

defaults.bgcolor = [0 0 0];

defaults.maxslices = 81;

defaults.autoslice = false;
defaults.autoslice_thresh = 1;

defaults.crop = [];

args = propval(varargin, defaults);

% Convert volumes into indices
anat_idx = anat_vol;
anat_idx(anat_idx>0) = 1:rows(anat_rgb);
over_idx = over_vol;
over_idx(over_idx>0) = 1:rows(over_rgb);

% Make the 3d matrix to store object coordinates
[i, j, k] = ind2sub(size(anat_vol), find(anat_idx));

anat_3d(:,1,1) = i;
anat_3d(:,1,2) = j;
anat_3d(:,1,3) = k;

% Shift dimensions to get alternative views
if args.shiftdim > 0
  anat_idx = shiftdim(anat_idx, args.shiftdim);
  over_idx = shiftdim(over_idx, args.shiftdim);
end

% Choose only slices with voxels included
if args.autoslice
  inc = sum(sum(over_vol)); % Sum over dimensions 1 and 2
  idx = find(inc>=args.autoslice_thresh); % Find those slices in dim 3 that have voxels
  anat_idx = anat_idx(:,:,idx);
  over_idx = over_idx(:,:,idx);
  
  % Save the autoslice index for future reference
  args.autoslice_idx = idx;
end

% The variable 'slices' now references into the perhaps autosliced,
% perhaps shiftdim'd dataset
if isempty(args.slices)
  
  n = size(anat_idx,3);
  if n > args.maxslices
    args.nslice = ceil(n/args.maxslices);
    warning('Dataset has %d slices; only %d will be displayed.', ...
            n, args.maxslices);
  end
  args.slices = 1:args.nslice:size(anat_idx,3);

end

% Figure out the grid on which to display slices
if isempty(args.ncols) && isempty(args.nrows) % auto grid
  args.ncols = ceil(sqrt(numel(args.slices)));
  args.nrows = ceil(numel(args.slices)/args.ncols);
elseif isempty(args.nrows) % auto rows
  args.nrows = ceil(numel(args.slices)/args.ncols);
elseif isempty(args.ncols) % auto columns
  args.ncols = ceil(numel(args.slices)/args.nrows);
end

% User can specify uniform cropping within each slice
if ~isempty(args.crop)
  anat_idx = anat_idx(args.crop(1,1):args.crop(2,1), args.crop(1,2):args.crop(2,2),:);
  over_idx = over_idx(args.crop(1,1):args.crop(2,1), args.crop(1,2):args.crop(2,2),:);
end

% OK! Ready to build the RGB image now. Figure out the dimensions of
% the total image:
y = size(anat_idx,1);
x = size(anat_idx,2);

imx = x*args.ncols;
imy = y*args.nrows;

im = nan(imy,imx,3);
im3d = nan(imy,imx,3);

%Create the slice images, and stick them into the proper portions of the image
s = 1;
for r = 0:(args.nrows-1)
  for c = 0:(args.ncols-1)

    % Loop for each of the three RGB channels
    for i = 1:3      

      % Make background matte
      slice = repmat(args.bgcolor(i),y,x);

      slice3d = repmat(nan, y, x);
      
      if s <= numel(args.slices)
      
        % Get data relating to this particular slice
        a = anat_idx(:,:,args.slices(s));
        o = over_idx(:,:,args.slices(s));
        
        % Get color data from RGB stuff
        slice(find(a)) = anat_rgb(a(find(a)), 1, i);
        slice(find(o)) = over_rgb(o(find(o)), 1, i);
          
        % Get 3d coord information
        slice3d(find(a)) = anat_3d(a(find(a)), 1, i);
      end
      
      slice_rgb(:,:,i) = slice;      
      slice_3d(:,:,i) = slice3d;
    end
    
    % Stick this slice into the big image
    im(r*y+1:(r+1)*y, c*x+1:(c+1)*x, :) = slice_rgb;
    im3d(r*y+1:(r+1)*y, c*x+1:(c+1)*x, :) = slice_3d;

    % Increment slice number
    s = s + 1;
  end
end

