function mr_fmontage_nogl(anat,func,mask,slices)
% use this if your system doesn't have opengl rendering

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

if nargin < 4
    slices = 1:size(func,3);
end

% the anatomical image will be displayed in grayscale
% the functional overlay will have a different colormap
cmap = [gray(128); jet(128)];
% scale the anatomical image for lower half of colormap
anat = fscale(anat,1,128);
% scale the anatomical image for the upper half
func = fscale(func,129,256);

[sfy,sfx,sfz] = size(func); % size of overlay image
[sy,sx,sz] = size(anat);    % size of background image

iscale = sy/sfy;

ns = length(slices);        % number of slices
nx = ceil(sqrt(ns));        % number of images in x direction
ny = ceil(ns/nx);           % number of images in y direction

axis image
axis ij
axis off
colormap(cmap)
hold on

for i = 1:ns
    ix = mod(i-1,nx);
    iy = floor((i-1)/nx);
    
    % x and y limits (for dimensions of functional image)
    fx = [1, sfx] + ix*sfx;
    fy = [1, sfy] + iy*sfy;    
    % limits of anatomical image are chosen so that the edges line up 
    x = fx + [.5, -.5] * (sfx/sx-1);
    y = fy + [.5, -.5] * (sfy/sy-1);
    
    func_exp = kron(func(:,:,slices(i)), ones(iscale,iscale));   % expand functional image
    mask_exp = logical(kron(mask(:,:,slices(i)), ones(iscale,iscale)));   % expand mask
    
    overlay_img = anat(:,:,slices(i));
    overlay_img(mask_exp)=func_exp(mask_exp); 
    
    image(x, y, overlay_img, 'Tag',num2str(slices(i)));
    
end
hold off

function fout = fscale(fin,foutmin,foutmax)
% scale an input image to a specified range
finmin = min(fin(:));
finmax = max(fin(:));
fout = (fin-finmin)/(finmax-finmin) * (foutmax-foutmin) + foutmin;