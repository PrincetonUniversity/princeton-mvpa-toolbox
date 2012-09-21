function [subj] = load_bv_pattern(subj,new_patname,maskname,filenames,varargin)

% Loads an BrainVoyager dataset into a subject structure
%
% [SUBJ] = LOAD_BV_PATTERN-AA(SUBJ,NEW_PATNAME,MASKNAME,FILENAMES,...)
%
% Adds the following objects:
% - pattern object called NEW_PATNAME masked by MASKNAME
%
% NEW_PATNAME is the name of the pattern to be created
% 
% MASKNAME is an existing boolean mask in the same reference space
% that filters which voxels get loaded in. It should 
%
% All patterns need a 'masked_by' mask to be associated with. The mask
% contains information about where the voxels are in the brain, and
% allows two patterns with different subsets of voxels from the same
% reference space to be compared
%
%
% FILENAMES is a cell array of strings, of BRIK filenames to load
% in. Just the stem, not the extension. If FILENAMES is a string,
% it will automatically get turned into a single-cell array for you.

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

% Load the mask
maskvol = get_mat(subj,'mask',maskname);
mDims   = size(maskvol);
mask    = find(maskvol);

% check mask isn't empty
if isempty(mask)
  error('Empty mask passed to load_bv_pattern()');
end

% Initialize the data structure
subj = init_object(subj,'pattern',new_patname);

if ischar(filenames)
  filenames = {filenames};
end

% Determine the size of the incoming data
for i=1:length(filenames)
  cur_filename = filenames{i};
  
  cur_mat = load(cur_filename);
  cur_dat = cur_mat.vtc_data;
  cur_size = size(cur_dat);
  bDims(i,:)= cur_size(2:4);
  bLen(i) = cur_size(1);
  
end
  clear cur_mat
  clear cur_dat

% Initialize the data structure
tmp_data = zeros(length(mask),sum(bLen));

nFiles = length(filenames);

disp( sprintf('Starting to load BV pattern from %i files',nFiles) );

for h = 1:nFiles
  fprintf('\t%i',h);

  %filenames should be strings of names of .mat files created from data
  %imported via NeuroElf, and saved using the save() function
  cur_filename = filenames{h};
  Vdata_mat = load(cur_filename);
  Vdata_dat = Vdata_mat.vtc_data;
    
  % Ensure that the mask dimensions match the data
  vDims = size(Vdata_dat);
  if any(vDims(2:4) ~= mDims(1:3))
    error('Mask dimensions do not match data');
  end
          
  % Reshape the data to be Voxels X Time
    % edited by Matt on 3/24/06 to allow MVPA to read 1-timepoint patterns
    % from BRIK
  if length(vDims) == 3
      vDims = [vDims 1];
  end
 
  %This part has been changed to work with the way VTC files are imported
  %by NeuroElf (time by X by Y by Z)
  Vdata_dat = reshape(Vdata_dat,prod(vDims(2:4)), vDims(1));
  
  % Apply the mask, and append to the matrix
  
  %the current TRs
  curTRs = sum(bLen(1:h-1))+1;
  curTRs = (curTRs:curTRs+bLen(h)-1);
  
  %write the data for each TR separately
  %"mask" contains non-zero indices; write only non-zero indices to
  %tmp_data
  tmp_data(:,curTRs) = Vdata_dat(mask,:);
     
end % for h

disp(' ');

% Store the data in the pattern structure
subj = set_mat(subj,'pattern',new_patname,tmp_data);

% Set the masked_by field in the pattern
subj = set_objfield(subj,'pattern',new_patname,'masked_by',maskname);

% Add the history to the pattern
hist_str = sprintf('Pattern ''%s'' created by load_bv_pattern',new_patname);
subj = add_history(subj,'pattern',new_patname,hist_str,true);

% Add information to the new pattern's header, for future reference
subj = set_objsubfield(subj,'pattern',new_patname,'header', ...
			 'ignore_absence',true);
subj = set_objsubfield(subj,'pattern',new_patname,'header', ...
			 'ignore_absence',true);

% This object was conceived under a tree. Store that information in
% the SUBJ structure
created.function = 'load_bv_pattern';
subj = add_created(subj,'pattern',new_patname,created);


