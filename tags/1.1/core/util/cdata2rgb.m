function [rgb cmap clim] = cdata2rgb(data, cmapname, clim)
% CDATA2RGB - Converts indexed image data to RGB with a specific colormap.
% 
% This function converts a 1-D or 2-D indexed color image DATA
% (with colormap CMAPNAME) into a true color RGB image. It can also
% apply caxis limiting as specified by CLIM in the process.
% 
% Inputs:
%
%  DATA - The 1-D or 2-D indexed color image.
%  
%  CMAPNAME - A string containing the name of the colormap to use.
%
%  CLIM - (Optional) Color axis limiting, so that values below CLIM(1)
%    and above CLIM(2) are clipped to the min and max color
%    values. Otherwise the full colormap is used. See IMAGESC for more
%    details.
%  
% Outputs:
%
%  RGB - The RGB true color image of data.
%  
%  CMAP - The colormap that data indexed into. (Because some
%    colormaps always put the value 0 at a specific color, this depends both on
%    CMAPNAME and DATA.)
%
%  CLIM - The value of CLIM used when generating the colormap
%    (min and max values for the color scale.)
%
% Examples:
%
% Convert the indexed image of 'peaks' data into an RGB image:
%  [rgb cmap clim] = cdata2rgb(peaks, 'jet'); 
%
% Convert the same, but fix -1 and 1 to be the min and max color range:
%  [rgb cmap clim] = cdata2rgb(peaks, 'jet', [-1 1]); 
%
% SEE ALSO:
%
%   VIEW_PATTERN_OVERLAY, BUILD_OVERLAY_RGB
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

f = figure('Visible', 'off'); % Make a temporary figure
try

  h = axes();
  
  % Automatically set clim if not specified 
  if nargin==2
    clim = [min(data(:)) max(data(:))];
  end
  if isempty(clim)
    clim = [min(data(:)) max(data(:))];
  end
 
  data = clip(data, clim(1), clim(2));
  
  % Plot the image
  i = imagesc(data); %, 'Parent', h);
  
  % Set the colormap (allows for intelligent colormaps)
  colormap(cmapname);
  
  % Retrieve the colormap
  cmap = colormap;
  n = rows(cmap);
  
  % Get the CData
  cdata = get(i, 'CData');
  
  if clim(2) == clim(1) % constant data goes in the middle of the colormap
    idx = repmat(round(n/2), size(cdata)); 
  elseif strcmp(get(i, 'CDataMapping'), 'scaled') 
    % normalize the cdata into the range [1, n], and round
    idx = round((double(cdata)-clim(1)) / (clim(2)-clim(1)) * (n-1) + 1);
  else
    idx = cdata;
  end
    
  % Check for some erroroneous conversion
  if any(idx(:)<1) || any(idx(:)>n) || any(isnan(idx(:)))
    error('Conversion error.');
  end
  
  % Using those indices, make the rgb version of the data
  rgb = zeros([size(cdata), 3]);
  
  c = cmap(idx, :);
  rgb = reshape(c, [size(idx) 3]);
  
catch
  e = lasterror;
  close(f);
  rethrow(e);
end

% Close the unneeded figure
close(f);

function [x] = clip(x, min, max)

x(x<min) = min;
x(x>max) = max;