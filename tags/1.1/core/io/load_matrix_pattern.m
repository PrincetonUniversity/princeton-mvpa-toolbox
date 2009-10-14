function [subj] = load_matrix_pattern(subj,new_patname,maskname,mat)

% Loads a 4D matrix into the SUBJ structure as a pattern
%
% [SUBJ] = LOAD_MATRIX_PATTERN(SUBJ,NEW_PATNAME,MASKNAME,MAT)
%
% Adds the following objects:
% - pattern object called NEW_PATNAME masked by MASKNAME
%
% Creates a pattern object in the subj structure based on a 4D
% (x,y,z,t) matrix MAT. If your matrix's dimensions aren't in this
% order, use the PERMUTE function to reorder them first.
%
% Requires you to already have created a mask. If you don't have a
% mask, then read the Howto 'How do I create a pattern
% without a mask?' in the manual at:
%
%   http://www.csbmb.princeton.edu/mvpa/docs/manual.htm
%
% You will need to a proper boolean 3D mask if you want to figure out
% where your voxels are in the brain.
%
% This function doesn't do much error-checking to compare the
% dimensions and number of allowed voxels in the mask and pattern.
%
% This is going to be fairly memory-intensive, since it's going to
% have to make a copy of your MAT to reshape it.
%
% Currently, takes no optional arguments.
%
% TO DO
%
% - create a [1 1 nVox] mask automatically if an empty MASKNAME
% is fed in, or maybe have an optional boolean argument
% 'create_mask' that will create a mask of mask MASKNAME
%
% - it would be nice if this could also deal with 2D (nVox x
% nTimepoints) matrices too
%
% - improve the error-checking for the size of the mask
% dimensions/nVox and the pattern dimensions/nVox
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


% Load the mask
maskvol = get_mat(subj,'mask',maskname);
mDims   = size(maskvol);
maskidx    = find(maskvol);

% check mask isn't empty
if isempty(maskidx)
  error('Empty mask passed to load_matrix_pattern()');
end

% Initialize the data structure
subj = init_object(subj,'pattern',new_patname);

vDims = size(mat);
if length(vDims)~=4
  % if you're just feeding in a 2D (nVox x nTimepoints) matrix,
  % then you can just call INIT_OBJECT and SET_MAT directly
  error('Your input matrix must be 4D (x,y,z,t)');
end

mDims = size(maskvol);
if prod(mDims)~=prod(vDims(1:3))
  error('Your mask and data seem to be of different dimensions');
end

disp( sprintf('Starting to load pattern from matrix') );

% Reshape the data to be nVox X nTimepoints
mat = reshape(mat,prod(vDims(1:3)), vDims(4));

mat = mat(maskidx,:);

disp(' ');

% Store the data in the pattern structure
subj = set_mat(subj,'pattern',new_patname,mat);

% Set the masked_by field in the pattern
subj = set_objfield(subj,'pattern',new_patname,'masked_by',maskname);

% Add the history to the pattern
hist_str = sprintf('Pattern ''%s'' created by load_matrix_pattern',new_patname);
subj = add_history(subj,'pattern',new_patname,hist_str,true);

% This object was conceived under a tree. Store that information in
% the SUBJ structure
created.function = 'load_matrix_pattern';
subj = add_created(subj,'pattern',new_patname,created);

