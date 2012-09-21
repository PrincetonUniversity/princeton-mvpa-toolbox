function [subj] = load_bv_mask(subj,new_maskname,filename,varargin)

% Loads an AFNI dataset into the subj structure as a mask
% 
% [SUBJ] = LOAD_BV_MASK-AA(SUBJ,NEW_MASKNAME,FILENAME,...)

% Author: Alex Ahmed (alex.ahmed AT yale DOT edu)

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

% To load a mask named "filename.msk" from Brainvoyager, use the following NeuroElf command:
% maskObject = xff('filename.msk');
% mask = maskObject.Mask;
%
% Use this variable as your "filename" input for this script.


defaults.sub_brik = [];
defaults.logical = false;
defaults.filter_by = [];
args = propval(varargin,defaults);

% Initialize the new mask
subj = init_object(subj,'mask',new_maskname);

V = filename;

if isempty(find(V,1))
  error('There were no voxels active in the %s mask',filename);
end

% Does this consist of solely ones and zeros?
if length(find(V)) ~= (length(find(V==0))+length(find(V==1)))
  fprintf('Setting all non-zero values in the mask to one');
  V(find(V)) = 1;
end

if args.logical
  V = logical(V);
end

% Store the data in the new mask structure
subj = set_mat(subj,'mask',new_maskname,V);

% Add the AFNI header to the patterns
hist_str = sprintf('Mask ''%s'' created by load_afni_pattern',new_maskname);
subj = add_history(subj,'mask',new_maskname,hist_str,true);

% Add information to the new mask's header, for future reference
subj = set_objsubfield(subj,'mask',new_maskname,'header', ...
			 'ignore_absence',true);
subj = set_objsubfield(subj,'mask',new_maskname,'header', ...
			 'ignore_absence',true);

% Record how this mask was created
created.function = 'load_bv_mask';
subj = add_created(subj,'mask',new_maskname,created);

