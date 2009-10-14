function [subj neighbor_idx] = create_spatial_avg_pat(subj, patname, maskname, varargin)

% Creates spatially averaged version of a given pattern.
%
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

defaults.window_i = -1:1;
defaults.window_j = -1:1;
defaults.window_k = -1:1;
defaults.new_patname = '';
defaults.use_neighbor_idx = [];

args = propval(varargin, defaults);

if isempty(args.new_patname)
  args.new_patname = [patname, '_savg'];
end

% Create adjacency list for each voxel:

% get the numerical data
pat = get_masked_pattern(subj, patname, maskname);
mask = get_mat(subj, 'mask', maskname);

% list of indices in 'mask' each voxel is located
voxel_idx = find(mask);
maskdims = size(mask);

% create new pattern to store spatially averaged
newpat = zeros(size(pat));


% Calculate the valid neighborhood of each voxel
neighbor_idx = args.use_neighbor_idx;

nVoxels = size(pat, 1);

fprintf('Starting create_spatial_avg_pat on ''%s'', %d voxels\n\tprogress:', ...
        patname, nVoxels);

update_interval = round(nVoxels/10);

for v = 1:nVoxels

  % if neighbor indexes wasn't passed in, calculate them
  if isempty(args.use_neighbor_idx)
    
    % find voxel's location in 3D space
    [v_i, v_j, v_k] = ind2sub(size(mask), voxel_idx(v));
    
    % generate the [i,j,k] locations of each neighbor
    [i, j, k] = ndgrid(args.window_i + v_i, args.window_j + v_j, ...
                       args.window_k + v_k);

    % filter out any invalid indices
    valid_idx = inrange(i(:), [0 maskdims(1)]) & ...
        inrange(j(:), [0 maskdims(2)]) & ...
        inrange(k(:), [0 maskdims(3)]);
    
    i = i(find(valid_idx));
    j = j(find(valid_idx));
    k = k(find(valid_idx));
    
    % find indices of neighbors in 'mask':
    neighbor_idx{v} = sub2ind(size(mask), i, j, k);
    
    % remove indices of masked out neighbors
    neighbor_idx{v} = neighbor_idx{v}( find(mask(neighbor_idx{v}) == ...
                                          1) );
    
    % now convert back into voxel index:
    for u = 1:numel(neighbor_idx{v})
      neighbor_idx{v}(u) = find(voxel_idx == neighbor_idx{v}(u));
    end

  end
  
  % spatially average neighborhood
  if ~isempty(neighbor_idx{v})
    newpat(v,:) = mean( pat(neighbor_idx{v}, :));
  end
  
  % output progress, since this can take a long time
  if mod(v, update_interval) == 0
    fprintf(' %.2f', v/nVoxels);
  end
  
end

% add the new object
subj = initset_object(subj, 'pattern', args.new_patname, newpat, ...
                   'masked_by', maskname);

fprintf('\nPattern ''%s'' created by create_spatial_avg_pat\n', ...
        args.new_patname);

%%%%%%%%%%%%%%%%%%%
% helper functions

function [out] = inrange(var, range)

out = var > range(1) & var <= range(2);
