function [adj_list scratch] = create_adj_list(subj, maskname, varargin)

% Creates a list of neighbours for each voxel
%
% [ADJ_LIST] = CREATE_ADJ_LIST(SUBJ,MASKNAME, ...)
%
% This loops over all the voxels in the mask. For each
% voxel, it looks to see which of the neighboring voxels
% are included in the mask. The neighbourhood can be
% specified in the NEIGHBOURHOOD.
%
% ADJ_LIST is a zero-padded matrix (nvox_active_in_mask x
% nvox_in_full_sphere), with each row containing the list of
% neighbor-voxel indices contained within a searchlight
% focused on that centre-voxel.
%
% In the future, we may want to cache this as a field in the
% mask somehow, or even create an object for it, but for now
% it's quick enough that we can just recompute it each time.
%
% ADJ_FUNCT (optional, default = 'adj_sphere'). This
% is the function that determines the shape of the
% neighbourhood used to determine which voxels are
% considered 'adjacent'.
%
% Any unused varargin args will be passed onto the inner ADJ
% logic function, e.g. ADJ_SPHERE.M.
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


defaults.adj_funct = 'adj_sphere';
[args unused] = propval(varargin, defaults);

% Get the function handle and name
[fhandle fname] = arg2funct(args.adj_funct);

% get the numerical data
mask = get_mat(subj, 'mask', maskname);

% Create the adjacency list for each voxel using the
% user-specified function
fprintf('%s: creating ''%s'' adjacency list of mask ''%s''\n', ...
        mfilename, args.adj_funct, maskname)

[adj_list scratch] = fhandle(mask,unused{:});



