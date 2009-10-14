function [adj_list_pat_idx scratch adj_list_mask_idx adj_neighb_counts] = adj_sphere(mask,varargin)

% Creates adjacency list using spherical neighbourhoods
%
% [ADJ_LIST_PAT_IDX SCRATCH ADJ_LIST_MASK_IDX ADJ_NEIGHB_COUNTS] = ADJ_SPHERE(MASK, ...)
%
% Create an adjacency list using a spherical neighbourhood
% function. See CREATE_ADJ_LIST for more information.
%
% This is designed to be as fast and memory efficient as we
% can make it. First, we create the offsets for a sphere of
% the right size. Then, for each voxel, we add the offsets
% to its voxel coordinates, to get a list of coordinates for
% that sphere. Then, we convert these into indices relative
% to the mask, throw away out-of-bounds voxels and voxels
% excluded by the mask, and then store the indices for that
% sphere (both relative to the mask, and relative to the
% pattern).
%
% Comparison with ADJ_SPHERE.M - this version spits out the
% adjacency lists as zero-padded matrices, rather than cell
% arrays. It's also based on Matt Weber's code for speed
% devilishness.
%
% MASK = boolean 3D matrix, showing which voxels should be
% included in the analysis.
%
% ADJ_LIST_PAT_IDX is the zero-padded (nvox_active_in_mask x
% nvox_in_full_sphere).  Each row contains the indices
% (relative to the pattern) of all the voxels within a
% sphere. See below for more details. N.B. This is a
% 'singles' matrix.
%
% SCRATCH contains mainly the ARGS after being passed
% through PROPVAL. This is just for book-keeping later.
%
% ADJ_LIST_MASK_IDX as per ADJ_LIST_PAT_IDX, but with
% indices relative to the mask.
%
% ADJ_NEIGHB_COUNTS = NVOX_ACTIVE_IN_MASK x 1 vector,
% containing the size of each corresponding neighborhood
% (i.e. non-zero voxel indices) in ADJ_LIST_PAT_IDX.
%
% RADIUS (optional, default = 2). Radius of the
% searchlight sphere.
%
% xxx this function INCLUDES the center voxel in the
% adjacency list.
%
% You can specify non-integer radii, to get finer control
% over the shape of your sphere.
%
% Just to give you some intuitions about radii for a 3x3
% cube:
%
% - a radius of 1 is a 3D plus sign
%
% - a radius of sqrt(2) adds the voxels that touch the edges
% of the center voxel
%
% - a radius of sqrt(3) gives you a 3x3 cube
%
% - a radius of 2 gives you a 3x3 cube, as well as an
% extra voxel on the center of each face
%
% - a radius of sqrt(5) gives you a 3x3 cube, with a plus
% sign on each face (we think)
%
% See TUTORIAL_SPHERES on the MVPA wiki for more information.

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

defaults.verbose = true;
defaults.radius = 2;
defaults.include = 1:count(mask);

args = propval(varargin,defaults);
%%% this piece of code turns the args fields into normal variables.
afields = fields(args);
for i = 1:length(afields)
    thisvar = afields{i};
    eval([thisvar ' = args.' thisvar ';']);
end

if radius<0
  error('Radius can''t be negative');
end

if args.verbose
  dispf('\tSphere radius = %.1f',radius);
end

% book-keeping
scratch.args = args;
scratch.funct_name = mfilename;

% turn it into logicals so that we can do some funky
% indexing later, and to save memory
mask = logical(mask);

if args.verbose
  disp('Creating spherical envelope...');
end

% create the sphere mask that we'll pass over the volume
% basically, we add this to a row-wise repmat of every voxel's
% 3D coordinates to get the 3D coordinates of the sphere centered
% on that voxel.

% OFFSETS = nvox_in_full_sphere x 3, where each row contains
% the offset values for that position in the sphere,
% e.g. the center voxel's OFFSETS row will be [0 0 0]
%
% these OFFSETS will be added to the center voxel's
% coordinates to create the x,y,z coordinates for the
% sphere.
offsets = [];

% we want to allow for the possibility of non-integer
% radii. however, we need the CEIL call here to convert the
% OFFSETS offsets into integers (because we are going to
% use these to index into the MASK matrix)
ceil_radius = ceil(radius);

for x = -1*ceil_radius:ceil_radius
  for y = -1*ceil_radius:ceil_radius
    for z = -1*ceil_radius:ceil_radius
      if sqrt(x^2+y^2+z^2) <= radius
        % append the current offset-triplet to the next row
        offsets(end+1,:) = [x y z];
      end
    end
  end
end

% the number of voxels in each sphere (before truncation,
% passing through the mask etc.)
nvox_in_full_sphere = size(offsets,1);

if args.verbose
  % transform the MASK into 3D subscripts
  disp('Transforming mask indices into subscripts...');
end
% dimensions of the volume, e.g. 64 x 64 x 34
mask_dims = size(mask);

% MASK_COORDS = nvox_active_in_mask x 3. These are the x,y,z
% coordinates of the active voxels in the mask
[mask_coords(:,1) mask_coords(:,2) mask_coords(:,3)] = ind2sub(mask_dims,find(mask));
nvox_active_in_mask = size(mask_coords,1);

% Create a sphere (with its own list of x,y,z
% coordinates) centered on each voxel. Throw out any
% coordinates that are outside the boundaries of the
% volume.

% ADJ_LIST_PAT_IDX (NVOX_ACTIVE_IN_MASK x
% NVOX_IN_FULL_SPHERE) contains the indices (relative to the
% pattern) of all the voxels within each sphere. Each row
% contains a sphere's worth of voxel indices. Some spheres
% may be truncated, containing fewer than
% NVOX_IN_FULL_SPHERE voxels, in which case that row will be
% zero-padded.
%
% A matrix of singles doesn't seem to speed the program up,
% but it may be useful/necessary for biiiiiig masks
adj_list_pat_idx = zeros(nvox_active_in_mask, nvox_in_full_sphere, 'single');

% ADJ_LIST_MASK_IDX (NVOX_ACTIVE_IN_MASK x
% NVOX_IN_FULL_SPHERE). Just like ADJ_LIST_PAT_IDX, except
% that these indices are relative to the mask.
adj_list_mask_idx = zeros(nvox_active_in_mask, nvox_in_full_sphere, 'single');

% ADJ_NEIGHB_COUNTS (nvox_active_in_mask x 1). Contains the
% size of each corresponding neighborhood (i.e. non-zero
% voxel indices) in ADJ_LIST_PAT_IDX.
adj_neighb_counts = zeros(nvox_active_in_mask, 1);

% MASK_TO_PAT_IDX is the same size as the mask, but it
% labels each voxel with its index (relative to the pattern)
mask_to_pat_idx = NaN(mask_dims);
mask_to_pat_idx(find(mask)) = 1:nvox_active_in_mask; 

if args.verbose
  disp('Passing the sphere over each voxel...');
end

for v = args.include %1:nvox_active_in_mask
  
  % VOX_COORDS_TILED = (nvox_in_full_sphere x 3).
  % Get the x,y,z coordinates for this voxel, and then tile
  % that row so that we can easily add the OFFSETS
  % matrix, to get the coordinates of the sphere
  vox_coords_tiled = repmat(mask_coords(v,:), nvox_in_full_sphere, 1);
  % SPHERE_COORDS = (nvox_in_full_sphere x 3), contains
  % the actual x,y,z coordinates for this sphere
  sphere_coords = vox_coords_tiled + offsets;
  
  % winnow voxels that lie outside the boundaries of the
  % volume
  badvoxels = find( sphere_coords(:,1)<1 | ... 
                    sphere_coords(:,2)<1 | ... 
                    sphere_coords(:,3)<1 | ... 
                    sphere_coords(:,1)>mask_dims(1) | ... 
                    sphere_coords(:,2)>mask_dims(2) | ... 
                    sphere_coords(:,3)>mask_dims(3));
  sphere_coords(badvoxels,:) = [];
  % SPHERE_IDX_MASK (1 x nvox_remaining_in_sphere). Get the indices
  % (relative to the mask volume) of the voxels inside the
  % sphere
  sphere_idx_mask = sub2ind(mask_dims, ...
                            sphere_coords(:,1), ...
                            sphere_coords(:,2), ...
                            sphere_coords(:,3));  
  
  % winnow voxels that aren't in the MASK.
  %
  % SPHERE_IDX_INCLUDED_IN_MASK = (1 x
  % nvox_remaining_in_sphere) boolean, describing whether
  % or not each of the voxels inside the sphere is
  % included in the mask
  %
  %   N.B. This works because the SPHERE_IDX_MASK indices are
  %   relative to the mask.
  sphere_idx_included_in_mask = mask(sphere_idx_mask);
  %
  % Throw away any of the voxels in the sphere that
  % aren't included in the mask.
  %  
  % N.B. this is equivalent to:
  %   sphere_idx_mask = sphere_idx_mask(find(sphere_idx_included_in_mask));
  sphere_idx_mask = sphere_idx_mask(sphere_idx_included_in_mask);
  
  % how many voxels in this sphere, after throwing away
  % out-of-bounds voxels and voxels excluded by the mask.
  nvox_remaining_in_sphere = length(sphere_idx_mask);

  % Convert indices relative to the mask into indices
  % relative to the pattern. (i.e., we know its index in
  % the 3D volume that includes 0's and 1's, but what is the
  % row index in the pattern?)
  sphere_idx_pat = mask_to_pat_idx( sphere_idx_mask );

  % add the sphere into the ADJ_LIST_PAT/MASK_IDX matrix
  % (the list of neighborhoods for each voxel, relative to
  % the mask/pattern)
  adj_list_mask_idx(v, 1:nvox_remaining_in_sphere) = sphere_idx_mask;
  adj_list_pat_idx(v, 1:nvox_remaining_in_sphere) = sphere_idx_pat;
  
  % compute the counts of neighborhood size for each voxel
  % in the ADJ_LIST_PAT_IDX
  adj_neighb_counts(v) = nvox_remaining_in_sphere;

  % spit out a marker every 10% of the way through
  if args.verbose
    made_progress = progress(v,nvox_active_in_mask);
  end
end
