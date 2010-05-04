function [subj] = load_afni_pattern(subj,new_patname,maskname,filenames,varargin)

% Loads an AFNI dataset into a subject structure
%
% [SUBJ] = LOAD_AFNI_PATTERN(SUBJ,NEW_PATNAME,MASKNAME,FILENAMES,...)
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
% in. Just the stem, not the extension. If FILENAMES is a string,
% it will automatically get turned into a single-cell array for you.
%
% e.g. to load in mydata.BRIK:
%   subj = load_afni_pattern(subj,'epi','wholebrain',{'mydata'});
%
% SUB_BRIKS (optional, default = []). By default, this will load in
% all the sub-briks. If you specify a range, then it will only load
% in those sub-briks. Useful if you only want part of your
% timecourse, or one/some of your contrasts. NOTE: this gets
% calculated at the very end of the function, after having loaded
% and concatenated all the briks specified by FILENAMES. If you
% only have one brik file to load in, you don't have to worry about
% this. But if you have multiple brik files, you need to specify
% the SUB_BRIKS range in terms of the total number of sub-briks
% that will be loaded in from all your files. Note: this indexing
% starts from *1*, not from zero, so you should feed in numbers
% that are one greater than their corresponding sub-brik numbers in
% afni
%
% SINGLE (optional, default = false). If true, will store
% the data as singles, rather than doubles, to save
% memory. Until recently, Matlab could store as singles, but
% none of its functions could do much with them. UPDATE:
% this has been reported to cause problems with some of the
% classification scripts.
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


defaults.sub_briks = [];
defaults.single = false;
args = propval(varargin,defaults);

% Load the mask
maskvol = get_mat(subj,'mask',maskname);
mDims   = size(maskvol);
mask    = find(maskvol);

% check mask isn't empty
if isempty(mask)
  error('Empty mask passed to load_afni_pattern()');
end

if ischar(filenames)
  filenames = {filenames};
end

% Determine the size of the incoming data
for i=1:length(filenames)
  cur_filename = filenames{i};
  [err,bInfo] = BrikInfo(cur_filename);
  if err
    error('Problem with BrikInfo and %s',cur_filename);
  end
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

  if args.single
    Vdata = single(Vdata);
  end
  
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
    % edited by Matt on 3/24/06 to allow MVPA to read 1-timepoint patterns
    % from BRIK
  if length(vDims) == 3
      vDims = [vDims 1];
  end
  Vdata = reshape(Vdata,prod(vDims(1:3)), vDims(4));
  
  % Apply the mask, and append to the matrix
  curTRs = sum(bLen(1:h-1))+1;
  curTRs = (curTRs:curTRs+bLen(h)-1);
  tmp_data(:,curTRs) = Vdata(mask,:);
     
end % for h

if ~isempty(args.sub_briks)
  if ~isnumeric(args.sub_briks) || ~isvector(args.sub_briks)
    error('Your SUB_BRIKS range must be a vector');
  end
  tmp_data = tmp_data(:,args.sub_briks);
end

disp(' ');

% Store the data in the pattern structure
subj = initset_object(subj,'pattern',new_patname,tmp_data, 'masked_by',maskname);

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
created.args = args;
subj = add_created(subj,'pattern',new_patname,created);


