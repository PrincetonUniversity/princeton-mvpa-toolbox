function mr_montage(vol,slices,method,croprect)

% creates a montage image for the slices specified in the slices vector

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

% if there are fewer than 4 arguments don't crop
if nargin < 4
    croprect = [1 1; size(vol,2) size(vol,1)];
end

% if there are fewer than than 3 arguments, choose a default plot method
if nargin < 3 | isempty(method)
    method = 1;
end

% if there are fewer than 2 arguments, show all the slices
if nargin < 2  | isempty(slices)
    slices = 1:size(vol,3);
end

ns = length(slices);    % number of slices
nx = ceil(sqrt(ns));    % number of images to display in x direction
ny = ceil(ns/nx);       % number of images to display in y direction
% this works okay when you are showing square images, but should be improved
% for rectangular images

dimx = croprect(2,1)-croprect(1,1)+1;   % x dimension of each image (voxels)
dimy = croprect(2,2)-croprect(1,2)+1;   % y dimension 

switch method
    case 1  % use subplot
        for i=1:ns
            subplot(nx,ny,i)
            imagesc(vol(croprect(1,2):croprect(2,2),croprect(1,1):croprect(2,1),slices(i)), ...
                'Tag',num2str(slices(i)))
            axis image
            axis off
        end
        
    case 2  % use a single set of plot axes, but multiple calls to imagesc
        for i=1:ns
            ix = mod(i-1,nx)+1;
            iy = floor((i-1)/nx)+1;
            imagesc([(ix-1)*dimx+1,ix*dimx],[(iy-1)*dimy+1,iy*dimy], ...
                vol(croprect(1,2):croprect(2,2),croprect(1,1):croprect(2,1),slices(i)), ...
                'Tag',num2str(slices(i)))
            hold on
        end
        axis image
        axis off
        hold off
        
    case 3  % combine images into one big image and make a single plot
        bigimage = zeros(dimy*ny,dimx*nx);
        for i=1:ns
            ix = mod(i-1,nx)+1;
            iy = floor((i-1)/nx)+1;
            bigimage((iy-1)*dimy+1:iy*dimy, (ix-1)*dimx+1:ix*dimx) = ...
                vol(croprect(1,2):croprect(2,2),croprect(1,1):croprect(2,1),slices(i));
        end
        imagesc(bigimage)
        axis image
        axis off
end
colormap(gray)