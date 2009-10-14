function [coords] = get_coords_from_mask(mask)

% Create nVox x 3 matrix of x,y,z coordinates from mask
%
% [COORDS] = GET_COORDS_FROM_MASK(MASK)
%
% COORDS (nVox x 3) contains the x,y,z coordinate of each active voxel in the
% boolean 3D mask MASK. As always, the order of the nVox
% voxels is the same as that returned by find(MASK)

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


[x y z] = ind2sub(size(mask),find(mask));

coords = [x y z];

