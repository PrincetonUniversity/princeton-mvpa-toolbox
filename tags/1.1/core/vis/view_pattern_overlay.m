function [h info] = view_pattern_overlay(subj, underlay, overlay, varargin)
% VIEW_PATTERN_OVERLAY - Overlays one pattern/mask onto another. (ie., montage)
%
% Usage:
%  h = view_pattern_overlay(subj, underlay, overlay, ...)
%  [h info] = view_pattern_overlay(subj, underlay, overlay, ...)
%
% VIEW_PATTERN_OVERLAY will plot overlay/underlay MR montages using
% data from the SUBJ structure or from matrices. Both the underlay and
% overlay can be given specific colormaps, and a number of
% tranformations/cropping can be applied when the image is
% rendered. (See BUILD_OVERLAY_RGB). VIEW_PATTERN_OVERLAY can also
% display 4D data as a set of subplots in a single figure with a
% consistent colormap scheme. Furthermore, VIEW_PATTERN_OVERLAY can
% apply on-demand preprocessing and masking before display, so that
% it's very easy to play with different views of the same
% data. Finally, VIEW_PATTERN_OVERLAY doesn't depend on OpenGL
% rendering, instead building RGB images, so it can be used to save
% image files without a Matlab JVM or display available.
%
% Outputs: 
%
%   H    - A handle or array of handles to the image axes of any montages.
%
%   INFO - A struct or array of structs containing several technical fields
%          describing the montage. See the bottom of this help for details.
%  
% Required Parameters: 
% 
%   UNDERLAY - Name of pattern/mask to use as anatomical substructure
%
%   OVERLAY  - Name of pattern/mask to be overlaid on top of the
%              anatomical underlay, *OR* a matrix of data to use
%              as the overlay (see below)
%  
% Optional Parameters:
%  
%   'over_samples' - The indices of the overlay that you want to be 
%                    displayed, as subplots. (Default: [1])
%
%   'over_mask'    - A name of a spatial mask to use for the overlay.
%                    This is required if a matrix overlay is used.  If
%                    using a pattern overlay, then those voxels in the
%                    pattern that intersect with the mask will be
%                    displayed.
%
%   'over_cmap'    - The colormap to use for the functional overlay.
%                    (Default: 'jet')
%
%   'over_clim'    - The colormap scaling limits for the functional
%                    overlay. See CLIMS in IMAGESC.
%
%   'under_cmap'   - The colormap to use for the anatomical underlay.
%                    (Default: 'darkgray')
%
%   'under_clim'   - The colormap scaling for the anatomical underlay.
%
%   'under_sample' - The index of the anatomical underlay to be
%                    displayed. Only applies if the underlay is a
%                    pattern with more than one timepoint. (Default: 1)
%
%   'filter'       - A logical function that determines what values of
%                    voxels will be displayed to the user (on-demand
%                    masking). There are several common built-in
%                    filters for thresholding (see below). Only one
%                    filter may be specified at a time.
%   
%   'gt', 'absgt' - 'Greater than' and 'Absolute Greater than' default filters.
%                   Set these to a scalar value to mask out voxels below this value.
%
%   'lt,  'abslt' - 'Less than' and 'Absolute Less than' default filters.
%                   Set these to a scalar value to mask out voxels above this value.
%
%   'filtermap'   - Instead of calculating the mask based on the voxel data in OVERLAY,
%                   the mask can be calculated on another pattern or matrix of the same
%                   size instead. (Default: overlay)
%
%   'rotation'    - Degrees of rotation applied to the final image. Use this to correct
%                   for distortions introduced by SHIFTDIM (see BUILD_OVERLAY_RGB).
%
%   'preproc'     - An arbitrary function to preprocess the data before displaying.
%
%   'saveto'      - A filename (no extension) to save the image to instead of
%                   plotting it to the screen. 
%   
%   'savefmt'     - The format in which the image should be
%                   saved. (Default: 'png')
%
%   'showtitle'   - Whether or not to show the title above the image.
%
% For more optional parameters to control rendering, see BUILD_OVERLAY_RGB.m. 
% Any of the optional arguments in BUILD_OVERLAY_RGB also apply to VIEW_PATTERN_OVERLAY.
%
% Examples:
%
%  - Show the pattern 'epi' overlaid on anatomatical data 'anat' using
%  the default colorschemes (grayscale for anat, 'jet' for 'epi').
%   
%   >> view_pattern_overlay(subj, 'anat', 'epi');
%
%  - The same as before, but restrict 'epi' to the 'temporal' mask:
% 
%   >> view_pattern_overlay(subj, 'anat', 'epi', 'over_mask', 'temporal');
% 
%  - Show the same patterns, but now shift the slice axis 1 dimension
%    from the default, and use a white background for printing:
% 
%   >> view_pattern_overlay(subj, 'anat', 'epi', 'over_mask', 'temporal', ...
%                           'shiftdim', 1, 'bgcolor', [1 1 1]);
%
%  - Use 'autoslice' to only show slices with voxels in a mask, to
%    zoom in on specific areas:
%
%   >> view_pattern_overlay(subj, 'anat', 'epi', 'over_mask', 'temporal', ...
%                           'autoslice', true);%
%
%  - You can plot part of a pattern in grayscale as underlay, and
%    highlight part of it in color by masking it:
%
%  >> view_pattern_overlay(subj, 'epi', 'epi', 'over_mask', 'temporal');
%
%  - Crop the top 5 and left 10 voxels from each slice (assuming 64x64 slices):
%
%  >> view_pattern_overlay(subj, 'anat', 'epi', 'crop', [5 10; 64 64]);
% 
%  - It's also common to filter the display to only show voxels whos values pass some
%    thresholding test. There are several ways of doing this:
%
%    Using built in thresholds:
%
%  >> view_pattern_overlay(subj, 'anat', 'anovascore', 'lt', 0.05);
%  >> view_pattern_overlay(subj, 'anat', 'tvalue', 'absgt', 1.2);
%   
%    Using a custom anonymous selection function: 
%
%  >> view_pattern_overlay(subj, 'anat', 'epi', 'filter', @(X) X.^2 <= 5);
%
%  - Anonymous functions can also be used to perform minor operations
%    on the data before display. For instance, you could display 1-p
%    instead of p for a pvalue:
%  
%  >> view_pattern_overlay(subj, 'anat', 'pval', 'preproc', @(p)1-p);
%
%    For more information on anonymous functions, see ANONDEMO.
%
%  - Or, you could mask based on a pattern of p-values, but display
%  the actual statistics:
%
% >> view_pattern_overlay(subj, 'anat', 'tstat', 'lt', 0.05, ...
%                         'filtermap', 'pvals');
% 
% For a more detailed tutorial with images as well as examples, see
% the online MVPA wiki.
%
% "Info" structure specification (experts only):
%
%   info.args: All arguments to VIEW_PATTERN_OVERLAY
%   info.over_cmap: The final colormap for the overlay
%   info.over_clim: The final color scaling for the overlay
%   info.imrgb: The RGB image to be displayed/saved
%   info.im3d: An equivalent RGB image where each color channel stores
%              the I,J,K coordinates of the plotted voxel.
%   info.buildargs: The arguments used by BUILD_OVERLAY_RGB (e.g., 
%               slices, cropping, etc.)
% 
% SEE ALSO:
%  
%   BUILD_OVERLAY_RGB, CDATA2RGB

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


% Default parameters:
defaults.over_samples = 1;
defaults.over_mask = [];
defaults.over_cmap = 'jet';
defaults.over_clim = [];
defaults.over_alpha = [];

defaults.srows = [];
defaults.make_colorbar = true;

defaults.under_clim = [];
defaults.under_cmap = 'darkgray';
defaults.under_sample = 1;

defaults.filtermap = [];
defaults.filter = [];
defaults.gt = [];
defaults.lt = [];
defaults.absgt = [];
defaults.abslt = [];

defaults.rotation = 0;

defaults.preproc = [];

defaults.saveto = [];
defaults.savefmt = 'png';

defaults.showtitle = true;

[args unused] = propval(varargin, defaults);

% Check for obvious usage errors
args = validate(subj, underlay, overlay, args);

% Retrieve the patterns that are going to be plotted.

if ~isstr(overlay) % If they provided a matrix, use that and the
                   % provided mask
  if isempty(args.over_mask)
    error('Must specify a mask if giving a matrix as overlay.');
  end

  over_vol = get_mat(subj, 'mask', args.over_mask);
  over_data = overlay;

else % Otherwise, use the mask/pattern that they specified
  
  over_type = find_obj(subj, overlay);
  if regexp(over_type, 'pattern') % they specified a pattern

    if isempty(args.over_mask)  % Find the right mask to use
      args.over_mask = get_objfield(subj, 'pattern', overlay, 'masked_by');
    end
    
    % Make sure that only voxels in both reference and overlay mask 
    % actually get plotted
    over_ref = get_ref_vol(subj, overlay);
    over_idx = over_ref;
    over_idx(over_idx>0) = 1:count(over_idx);
    
    % Grab the overlay volume and overlay data
    over_mask = get_mat(subj, 'mask', args.over_mask);
    over_mask = over_ref & over_mask;

    % Get the data
    over_data = get_mat(subj, 'pattern', overlay);
    over_data = over_data(over_idx(over_mask(:)), :);

    % Update the reference volume
    over_vol = single(over_mask);
    
  elseif regexp(over_type, 'mask') % They specified a mask
     
    over_vol = get_mat(subj, 'mask', overlay);
    over_data = over_vol(over_vol>0);
    
  else
    error('Invalid overlay specified.');
  end
 
end

% We only need those patterns that will actually get plotted:
over_data = double(over_data(:, args.over_samples));

% Filter out unwanted voxels
if ~isempty(args.filter)

  if isstr(args.filtermap)
    fmap_data = get_mat(subj,'pattern',args.filtermap);
    fmap_data = fmap_data(:,args.over_samples(1));
    fmap_vol = get_ref_vol(subj,args.filtermap);
  else
    fmap_data = args.filtermap;
    fmap_vol = over_vol;
  end  
 
  % Compute which parts of the overlay should be dynamically masked
  fmap_pass = args.filter(fmap_data);
  fmap_idx = find(fmap_vol);
  fmap_vol(fmap_idx(~fmap_pass)) = 0;

  % Create the idx volume to compute masked pattern indices
  over_idx = over_vol;
  over_idx(over_idx>0) = 1:count(over_idx);

  % Apply the mask
  over_mask = over_vol & fmap_vol;

  % Now figure out which parts of the original pattern survived
  over_data = over_data(over_idx(over_mask),:);

  % Update the reference volume
  over_vol = double(over_mask);
end  

% Strip any NaNs from the mask; we can't display those!
nanidx = find(any(isnan(over_data),2));
over_idx = find(over_vol);

over_vol(over_idx(nanidx)) = 0;
over_data = over_data(exclude(nanidx,rows(over_data)), :);

% Warn the user so they know voxels are being excluded
if ~isempty(nanidx)
  warning(['%d NaNs were detected in the overlay. These voxels will be ' ...
           'automatically masked.'], count(nanidx));
end

% If specified, apply some basic preprocessing to the data
if ~isempty(args.preproc)
  over_data = args.preproc(over_data);
end

% Now retrieve anatomical data:
under_type = find_obj(subj, underlay);

if regexp(under_type, 'mask') 

  anat_vol = get_mat(subj, 'mask', underlay); % mask data is just ones
  anat_data = anat_vol(anat_vol>0);
  
elseif strcmp('pattern', under_type(2:end))
  
  anat_data = get_mat(subj, 'pattern', underlay);
  anat_vol = get_ref_vol(subj, underlay); 

else
  error('Invalid underlay type.');
end

% Make sure all calculations are carried out correctly
anat_data = double(anat_data);

% Build string representations of arguments for later titles
if ~isstr(overlay) % Get a string for 'overlay', which might have been numeric
  overlay = inputname(3);
  if isempty(overlay)
    overlay = 'matrix';
  end    
end     

% Build string representation of filter string for display
if ~isempty(args.filter)
  filterstr = func2str(args.filter);
else
  filterstr = 'All';
end

% Append preproc to overlay name if applicable
if ~isempty(args.preproc) 
  overlay = sprintf('%s[%s]', overlay, func2str(args.preproc));
end

% Get the rgb data for both overlay and underlay
[over_rgb over_cmap over_clim] = cdata2rgb(over_data, args.over_cmap, args.over_clim);
[anat_rgb] = cdata2rgb(anat_data(:,args.under_sample), args.under_cmap, args.under_clim);

% Fix to avoid breaking the colorbars
if over_clim(1) == over_clim(2)
  over_clim(1) = over_clim(2) - 1;
end

info = bundle(args, over_cmap, over_clim);

% Now, we loop over each sample of the overlay we wish to display
if cols(over_data) > 1
   
  % Generate a reasonable grid to display slices over
  if isempty(args.srows)
    args.srows = ceil(sqrt(cols(over_data)));
  end
  
  m = args.srows;
  n = ceil(cols(over_data)/m);

  if ~isempty(args.saveto)
    f = figure('Visible', 'off');
  end

  info_orig = info; clear info;
  
  % Grab the overlays for each
  for i = 1:numel(args.over_samples)
    
    h(i) = subplot(m,n,i);
    
    % Get the image
    [imrgb im3d buildargs] = build_sample(anat_vol, anat_rgb, over_vol, over_rgb(:,i,:), over_data(:,i,:), args, unused);
        
    info(i) = mergestructs(info_orig, bundle(imrgb, im3d, buildargs));

    image(imrgb);
    axis image;
    axis off;

    if args.showtitle
      titlef('Underlay: %s[%d], Overlay: %s[%d], Filter: %s', ...
             underlay, args.under_sample, overlay, args.over_samples(i), filterstr);
    end
    
  end

  if ~isempty(args.saveto)
    saveas(f, [args.saveto '.' args.savefmt], args.savefmt);
    close(f);
  end

  if args.make_colorbar
    f = figure('Name', 'Colormap');
    make_colorbar(over_cmap, over_clim); axis off;
  end
  
    
  if ~isempty(args.saveto)
    saveas(f, [args.saveto '_cmap.' args.savefmt], args.savefmt);
    close(f);
  end

  
else  

  % Get the image
  [imrgb im3d buildargs] = build_sample(anat_vol, anat_rgb, over_vol, over_rgb, over_data, args, unused);

  info = mergestructs(info,bundle(imrgb, im3d, buildargs));
  
  if ~isempty(args.saveto)
    f = figure('Visible', 'off');
  end
  
  % Plot it
  h = image(imrgb);
  axis image;
  axis off;

  make_colorbar(over_cmap, over_clim);
  if args.showtitle
    titlef('Underlay: %s[%d], Overlay: %s [%d], Filter: %s', ...
           underlay, args.under_sample, overlay, args.over_samples, filterstr);
  end

  if ~isempty(args.saveto)
    saveas(f, args.saveto, args.savefmt);
    close(f);
  end

end

function [imrgb im3d buildargs] = build_sample(anat_vol, anat_rgb, over_vol, over_rgb, over_data, args, unused)
    
  % Get the image
  [imrgb im3d buildargs] = build_overlay_rgb(anat_vol, anat_rgb, over_vol, over_rgb, unused{:});
  
  % Rotate if desired
  if args.rotation ~= 0
    imrgb = imrotate(imrgb, args.rotation, 'bicubic');
  end



%%%%%%%%%%%%%%% Utility functions
function [args] = validate(subj, underlay, overlay, args)

% Don't allow more than one filter
if sum([~isempty(args.filter) ~isempty(args.gt) ~isempty(args.lt) ...
        ~isempty(args.absgt) ~isempty(args.abslt)]) > 1
  error('Cannot specify more than one filter simultaneously.');
end

% Set the default map to use for the filter as the overlay itself
if isempty(args.filtermap)
  args.filtermap = overlay;
  if ~ischar(args.filtermap) & cols(args.filtermap) > 1
    args.filtermap = args.filtermap(:,args.over_samples);
  end
end

% If filter is empty, check for default filters
if isempty(args.filter)
  
  if ~isempty(args.gt)
    args.filter = eval(sprintf('@(X)(X > %g)', args.gt));
  elseif ~isempty(args.lt)
    args.filter = eval(sprintf('@(X)(X < %g)', args.lt));
  elseif ~isempty(args.abslt)
    args.filter = eval(sprintf('@(X)(abs(X) < %g)', args.abslt));
  elseif ~isempty(args.absgt)
    args.filter = eval(sprintf('@(X)(abs(X) > %g)', args.absgt));
  end
  
else
  % Check that filter is a function handle  
  args.filter = arg2funct(args.filter);

  % Check that we can create a single mask using filter
  if length(args.over_samples) > 1
    error(['Cannot apply dynamic masking using filter to multiple ' ...
           'time samples. Create a mask first, then use that instead.']);
  
  end  

  % Cannot apply filter to masks
  if isstr(overlay) && exist_object(subj,'mask',overlay)
    error(['Cannot apply dynamic masking using filter to a mask ' ...
           'overlay.']);
  end  
end

% Check the preproc function to make sure it makes sense
if ~isempty(args.preproc)
  args.preproc = arg2funct(args.preproc);
  
  before = rand(500,1)-0.5;
  after = args.preproc(before);
  if size(before) ~= size(after)
    error('Preprocessing function does not preserve size.');
  end
end

function [h] = make_colorbar(over_cmap, over_clim)

  colormap(over_cmap);
  h = colorbar;           % Set up the colorbar
  c = get(h, 'Children'); % data in the colorbar;

  set(c,'YData', over_clim); % Change the YData to match the actual clims
  set(h,'YLim', over_clim);  % Change the YLim to match the actual clims  
