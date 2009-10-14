function [A sizes] = fill_clusters(vol, adj_list)
% Fills in all non-zero clusters with unique sequential integers.
%
% Usage:
%   [A] = FILL_CLUSTERS(VOL)
%   [A] = FILL_CLUSTERS(VOL, ADJ_LIST)
% 
% Operates on a 3D mask volume. Iteratively searches out
% connectivity for only the non-zero voxels in VOL, using the
% adjacency list provided in ADJ_LIST (if one is not provided, a
% spherical adjacency list will be calculated with radius 1). All
% clusters are numbered sequentially, and a pattern vector with
% cluster assignments to non-zero voxels is returned as A.
%
% This is a very fast algorithm, depending only on the number of
% non-zero voxels in VOL.
% 
% Outputs:
%
%    A - Vector of assignments of non-zero indices within vol.
%
% Inputs:
%
%    VOL      - 3D mask volume for clustering.
%
%    ADJ_LIST - Its associated adjacency list. (default: calculates
%               an adjacency list 

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

% Start with voxel assignments for each dude.
A = 1:count(vol(:));
if isempty(A)
  sizes = [];
  return;
end

if nargin==1
  adj_list = adj_sphere(vol, 'radius', 1);
end

% Iteratively expand each cluster to include its neighbors
growing = true;  
while growing

  % Assume stopped so that if no growth, loop will end
  growing = false;
  
  % Get the current range of clusters assignments
  crange = unique(A);

  %dispf('Beginning new pass (%d clusters)...', count(crange));
  for n = crange

    % Find all voxels in this cluster
    idx = find(A==n);

    if ~isempty(idx)
      
      % Find all their neighbors
      nbrs = adj_list(idx,:);
      
      % Get the clusters that their neighbors belong to
      nbrsclusts = unique(A(nbrs(nbrs>0)));
      nbrsclusts = nbrsclusts(nbrsclusts~=n); % remove any
                                              % belonging to us to
                                              % speed up the next line
      
      % Get the locations of voxels belonging to these clusters
      growth = ismember(A, nbrsclusts);
      
      % Make these guys be our cluster
      A(growth) = n;
      
      % Check for growth
      if sum(growth) > 0
        %dispf('Grew cluster %d by %d voxels.', n, sum(growth));
        growing = true;
      end 
    
    end % If it was empty (already absorbed), just skip
    
  end
    
end

% Rename the assignments to be sequential
crange = unique(A);
for n = 1:numel(crange)
  A(A==crange(n)) = n;
  sizes(n) = count(A==n);  
end

