function [him h] = imagetxt(X, varargin)
% IMAGETXT - Plots an image with numbers in each square.
%
% Usage:
%
%  [hIM hText] = imagetxt(X, ...)
%
% IMAGETXT plots a given matrix X using IMAGESC, but then
% additionally plots text objects in the center of each pixel. This
% is useful for plotting correlation maps, in which color provides
% an overall impression and numbers fill out the details. 
%
% The default colormap is BLUEWHITERED, which plots negative values in
% blue, values close to zero in white, and positive values in red,
% which makes it easy to read black text written inside each square.
%
% Any arguments passed to IMAGETXT that IMAGETXT does not recognize
% will be passed to each TEXT command, so that fonts, interpreters,
% etc., can be controlled by the user.
%
% IMAGETXT returns the handle to the image object, hIM, and a matrix
% hText of handles to each individual text object.
%
% Optional Arguments:
%
%   'colormap' - The colormap to use. (Default: BLUEWHITERED)
%
%   'clim'     - The color limits of the colormap. (Default: full
%                range of data.)
%
%   'fmt'      - The string format of numeric values. (Default: '%.3f')
%
%   'pvals'    - A matrix of p-value the size of X. For each
%                p-value that's below PTHRESH, the text will be
%                plotted in white instead of black. (Thus marking
%                significance against dark squares.) (Default: all ones.)
%
%   'pthresh'  - P-value threshold for significance
%                testing. (Default: 0.05)

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

defaults.colormap = bluewhitered;
defaults.clim = [min(X(:)) max(X(:))];
defaults.fmt = '%.3f';
defaults.pthresh = 0.05;
defaults.pvals = ones(size(X)); % default: nothing is significant

[args unused] = propval(varargin, defaults);

him = imagesc(X, args.clim);
colormap(args.colormap);

for i = 1:rows(X)
  for j = 1:cols(X)

    if args.pvals(i,j) < args.pthresh
      h(i,j) = text(j,i, sprintf(args.fmt, X(i,j)), ...
           'HorizontalAlignment', 'center', 'Color', 'white', unused{:});        
    else    
      h(i,j) = text(j,i, sprintf(args.fmt, X(i,j)), ...
           'HorizontalAlignment', 'center', unused{:});    
    end
    
  end
end
