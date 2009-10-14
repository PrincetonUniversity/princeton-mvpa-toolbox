function mr_fmontage_vga(anat,func,mask,slices)
% functional montage superimposed on anatomical montage

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
cmap = [gray(128); hsv(128)];
% scale the anatomical image for lower half of colormap
anat = fscale(anat,1,128);
% scale the anatomical image for the upper half
func = fscale(func,129,256);

[sfy,sfx,sfz] = size(func); % size of overlay image
[sy,sx,sz] = size(anat);    % size of background image
ns = length(slices);        % number of slices
nx = ceil(sqrt(ns));        % number of images in x direction
ny = ceil(ns/nx);           % number of images in y direction

hold on

% need opengl rendering for alpha blending
set(gcf, 'Renderer', 'opengl')

for i = 1:ns
    ix = mod(i-1,nx);
    iy = floor((i-1)/nx);
    
    % x and y limits for the overlay image
    fx = [1, sfx] + ix*sfx;
    fy = [1, sfy] + iy*sfy;    

    % limits of anatomical image are chosen so that the edges line up 
    x = fx + [.5, -.5] * (sfx/sx-1);
    y = fy + [.5, -.5] * (sfy/sy-1);
    image(x, y, anat(:,:,slices(i)));
    
    % superimpose the functional image with unmasked voxels transparent
    image(fx, fy, func(:,:,slices(i)), 'Tag',num2str(slices(i)), ...
        'AlphaData', double(mask(:,:,slices(i))));
end
hold off

axis image
axis ij
axis off
colormap(cmap)

function fout = fscale(fin,foutmin,foutmax)
% scale an input image to a specified range
finmin = min(fin(:));
finmax = max(fin(:));
fout = (fin-finmin)/(finmax-finmin) * (foutmax-foutmin) + foutmin;

% function tout = tscale(fin,foutmin,foutmax)
% % scale an input image to a specified range
% tinmin = 0;
% tinmax = 15;
% tout = (fin-tinmin)/(tinmax-tinmin) * (foutmax-foutmin) + foutmin;
