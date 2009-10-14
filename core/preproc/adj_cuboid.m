function [adj_list_pat_idx scratch adj_list_mask_idx] = adj_cuboid(mask,varargin)

% Creates adjacency list using cuboid neighborhoods
%
% [adj_list_pat_idx scratch adj_list_mask_idx] = adj_cuboid(mask,varargin)
%
% Create an adjacency list using a rectangular neighborhood
% function. See GET_ADJACENCY and ADJ_SPHERE for more
% information.
%
% ADJ_LIST_PAT_IDX is the cell array of voxel indices
% (in terms of the patterns) required by GET_ADJACENCY.M
%
% SCRATCH contains mainly the ARGS after being passed
% through PROPVAL
%
% ADJ_LIST_MASK_IDX is a cell array much like ADJ_LIST_PAT_IDX,
% except the indices are in terms of the *mask*, rather than
% the pattern (active voxels alone). This is sometimes
% useful for debugging and visualizing mask shapes.
%
% WINDOW_I, WINDOW_J, WINDOW_K (optional, default =
% [-1:1]). These are the ranges that define the offsets
% (relative to the center-voxel) of neighbors that will be
% considered adjacent within the searchcuboid. You can think
% of them as defining the length of searchcuboid's sides. So
% [-1:1] produces a searchcuboid of SIDELENGTH 3.
%
% EXCLUDE_CENTER (optional, default = false). If you want to
% exclude the center voxel itself from the adjacency_list,
% set this to true.
%
% N.B. by defining complicated WINDOW_ args, one could
% specify funky non-cuboidal shapes. However, at the time of
% writing, this has not been tested - see
% UNIT_ADJ_CUBE.M.

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


% if ~exist('user_args','var')
%   user_args = struct();
% end
% if isempty(user_args)
%   user_args = struct();
% end

defaults.window_i = -1:1;
defaults.window_j = -1:1;
defaults.window_k = -1:1;
defaults.exclude_center = false;
args = propval(varargin,defaults);

maskdims = size(mask);

% get linear indices of each voxel into the mask
vox_idx = find(mask);
nVox = numel(vox_idx);

% get the ijk coordinates of each voxel in the mask
[v_i v_j v_k] = ind2sub(maskdims, vox_idx);

% we don't need this after all, because we're going to avoid
% preinitializing the ADJ_LIST matrices for now
%
% % the number of voxels in a cube
% neighb_size = ...
%     length(args.window_i) * ...
%     length(args.window_j) * ...
%     length(args.window_k);
% if args.exclude_center
%   neighb_size = neighb_size - 1;
% end

% now we make a mapping to go from a linear mask index to
% the row index of the corresponding voxel: this is
% equivalent to assigning numbers to each "1" in a mask
% according to the voxel # they represent

% NaN to catch errors if we index improperly
mask_to_pat_idx = NaN(maskdims);
mask_to_pat_idx(find(mask)) = 1:nVox; 

pat_to_mask_idx = convert_pat_to_mask_idx(mask);

% initial the adjacency list beforehand
adj_list_pat_idx = zeros(nVox,1);
adj_list_mask_idx = zeros(nVox,1);

for v = 1:nVox

  progress(v,nVox);

  % generate the [i,j,k] locations of each neighbor
  [i, j, k] = ndgrid(args.window_i + v_i(v), ...
                     args.window_j + v_j(v), ...
                     args.window_k + v_k(v));

  % find the indices of any invalid coordinates (i.e. that
  % go outside the bounds of the scanner's field of view)
  valid_idx = ... 
      inrange(i(:), [0 maskdims(1)]) & ...
      inrange(j(:), [0 maskdims(2)]) & ...
      inrange(k(:), [0 maskdims(3)]);
   
  % filter the coordinates to only contain these 'valid'
  % voxels
  i = i(find(valid_idx));
  j = j(find(valid_idx));
  k = k(find(valid_idx));

  % convert the valid coordinates into linear indices in the
  % mask. transpose to make into a row vector
  adj_m_idx = sub2ind(maskdims, i, j, k)';

  % now filter these against the linear mask indices of
  % voxels selected according to the mask: this is
  % equivalent to extracting only those neighbors that have
  % a "1" in the mask
  adj_m_idx = adj_m_idx(find (mask(adj_m_idx)) );

  % if we're excluding the center, remove that element from the
  % neighbors list
  if args.exclude_center
    v_mask_idx = pat_to_mask_idx(v);
    adj_m_idx = adj_m_idx( find(adj_m_idx ~= v_mask_idx) );
  end

  cur_neighb_size = length(adj_m_idx);
  
  % now we finally need to convert these linear mask indices
  % back to the row indices in the corresponding pattern
  % (i.e., we know its index in the 3D volume that includes
  % 0's and 1's, but what is the row index in the pattern?)
  %
  % both these matrices are zero-padded, and the number of
  % voxels in this neighborhood will be different each time,
  % so we need to adjust the indexing accordingly
  adj_list_pat_idx(v,1:cur_neighb_size) = mask_to_pat_idx( adj_m_idx );
  adj_list_mask_idx(v,1:cur_neighb_size) = adj_m_idx;
  
end

scratch.args = args;
scratch.funct_name = mfilename;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [out] = inrange(var, range)

% RANGE = (1 x 2) matrix containing upper and lower bounds
% (e.g. if this dimension of the mask has length 128, range
% = [0 128])
%
% VAR = vector of values, each of which comes from a
% different voxel's coordinate on a single dimension
%
% should we rewrite this so that var >= range(1), in which
% case you'd feed in a range of [1 128], in the above
% example??? xxx

out = var > range(1) & var <= range(2);



