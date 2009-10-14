function [coords] = get_coords_from_mask(mask)

% Create nVox x 3 matrix of x,y,z coordinates from mask
%
% [COORDS] = GET_COORDS_FROM_MASK(MASK)
%
% COORDS (nVox x 3) contains the x,y,z coordinate of each active voxel in the
% boolean 3D mask MASK. As always, the order of the nVox
% voxels is the same as that returned by find(MASK)


[x y z] = ind2sub(size(mask),find(mask));

coords = [x y z];

