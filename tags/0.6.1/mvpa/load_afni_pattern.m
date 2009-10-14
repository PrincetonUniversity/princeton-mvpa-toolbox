function [subj] = load_afni_pattern(subj,new_patname,maskname,filenames)

% Loads an AFNI dataset into a subject structure
%
% [SUBJ] = LOAD_AFNI_PATTERN(SUBJ,NEW_PATNAME,MASKNAME,FILENAMES)
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
% See the Howtos (xxx) section for tips on loading data without a
% mask
%
% FILENAMES is a cell array of strings, of BRIK filenames to load
% in. Just the stem, not the extension
%
% e.g. to load in mydata.BRIK:
%   subj = load_afni_pattern(subj,'epi','wholebrain',{'mydata'});

% This is part of the Princeton MVPA toolbox, released under the
% GPL. See http://www.csbmb.princeton.edu/mvpa for more
% information.


% Load the mask
maskvol = get_mat(subj,'mask',maskname);
mDims   = size(maskvol);
mask    = find(maskvol);

% check mask isn't empty
if isempty(mask)
  error('Empty mask passed to load_afni_pattern()');
end

% Initialize the data structure
subj = init_object(subj,'pattern',new_patname);

% Determine the size of the incoming data
for i=1:length(filenames)
  [err,bInfo] = BrikInfo(char(filenames{i}));
  bDims(i,:)= bInfo.DATASET_DIMENSIONS(1:3);
  bLen(i) = bInfo.DATASET_RANK(2);
end

% Initialize the data structure
tmp_data = zeros(length(mask),sum(bLen));

nFiles = length(filenames);

disp( sprintf('Starting to load AFNI pattern from %i BRIK files',nFiles) );

for h = 1:nFiles
  fprintf('\t%i',h);

  cur_filename = filenames{h};
  % Load the data from the BRIK file
  [err,Vdata,AFNIheads{h},ErrMessage]= BrikLoad(cur_filename);

  % Check for errors
  if err == 1
    error(sprintf('error in BrikLoad -%s',ErrMessage));
  end

  % Ensure that the mask dimensions match the data
  vDims = size(Vdata);
  if any(vDims(1:3) ~= mDims(1:3))
    error('Mask dimensions do not match data');
  end
          
  % Reshape the data to be Voxels X Time
  Vdata = reshape(Vdata,prod(vDims(1:3)), vDims(4));
  
  % Apply the mask, and append to the matrix
  curTRs = sum(bLen(1:h-1))+1;
  curTRs = (curTRs:curTRs+bLen(h)-1);
  tmp_data(:,curTRs) = Vdata(mask,:);
     
end % for h
  
disp(' ');

% Store the data in the pattern structure
subj = set_mat(subj,'pattern',new_patname,tmp_data);

% Set the masked_by field in the pattern
subj = set_objfield(subj,'pattern',new_patname,'masked_by',maskname);

% Add the history to the pattern
hist_str = sprintf('Pattern ''%s'' created by load_afni_pattern',new_patname);
subj = add_history(subj,'pattern',new_patname,hist_str,true);

% Add information to the new pattern's header, for future reference
subj = set_objsubfield(subj,'pattern',new_patname,'header', ...
			 'AFNI_heads',AFNIheads,'ignore_absence',true);
subj = set_objsubfield(subj,'pattern',new_patname,'header', ...
			 'AFNI_filenames',filenames,'ignore_absence',true);

% This object was conceived under a tree. Store that information in
% the SUBJ structure
created.function = 'load_afni_pattern';
subj = add_created(subj,'pattern',new_patname,created);


