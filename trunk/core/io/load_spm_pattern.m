function [subj] = load_spm_pattern(subj,new_patname,maskname,filenames,varargin)

% Loads an spm dataset into a subject structure
%
% [SUBJ] = LOAD_SPM_PATTERN(SUBJ,NEW_PATNAME,MASKNAME,FILENAMES,...)
%
% Adds the following objects:
% - pattern object called NEW_PATNAME masked by MASKNAME
%% Options
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
% FILENAMES is a cell array of strings, of .nii filenames to load
% in. Just the stem, not the extension. If FILENAMES is a string,
% it will automatically get turned into a single-cell array for
% you. If the string contains an asterisk, the string will be
% converted into a cell array of all matching files.
%
% e.g. to load in mydata.nii:
%   subj = load_spm_pattern(subj,'epi','wholebrain',{'mydata.nii'});
%
% SINGLE (optional, default = false). If true, will store the data
% as singles, rather than doubles, to save memory. Until recently,
% Matlab could store as singles, but none of its functions could do
% much with them. That's been improved, but it's possible that
% there may still be problems
%
%
%
%% License:
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
% =====================================================================
%
% NOTE: This function was written to allow for SPM5 compatability,
% and assumes SPM5 is installed and unmodified.  Specifically, this
% function makes use of .nii input/output functions in
% spm_dir/@nifti/private, strangely enough...

%% Defaults and setup
% single is used to set whether you'd like to open your data as a single
% precision instead of a double precision.  This allows you to save a
% signifigant amount of memory if you don't actually need double precision.
defaults.single = false;

%capture the arguements and populate the default values.
args = propval(varargin,defaults);


%% Check for spm functions
spmPres = which('spm_vol.m');
if isempty(spmPres)
  error('SPM not found.');
end

%% Mask Setup
maskvol = get_mat(subj,'mask',maskname);
mDims   = size(maskvol); %#ok<NASGU> %get the dimensions of the mask
mask    = find(maskvol);%get the relevant indexes of the mask (all non zero's)
mSize   = length(mask);%get the size of the mask

% check mask isn't empty
if isempty(mask)
  error('Empty mask passed to load_spm_pattern()');
end


%% Initialize the data structure
subj = init_object(subj,'pattern',new_patname);

%% Convert filenames to a cell array
%if the file name is an array of characters
if ischar(filenames)
    
  if ~isempty(strfind(filenames,'*'))
    [pat,jnk,jnk] = fileparts(filenames); %#ok<NASGU>
    tmp = dir(filenames);
    filenames = {tmp(:).name};
    if ~isempty(pat)
      for i=1:length(filenames)
	filenames{i} = [pat '/' filenames{i}];
      end
    end   
  else
    filenames = {filenames};
  end
  
elseif ~iscell(filenames)
  error('Filenames are not in form of char or cell.');
end

nFiles = length(filenames);

%% Initialize the data structure
tmp_data = zeros(mSize ,nFiles); %#ok<NASGU>

disp(sprintf('Starting to load pattern from %i SPM files',nFiles));

%% Create a volume structure
vol = spm_vol(filenames);


    %%%%%%%%%%%%%%%%%%%%%%
    %sylvains contribution
    %%%%%%%%%%%%%%%%%%%%%%

total_m = 0;

% compute total number of EPI images
for h = 1:nFiles
  [m n] = size(vol{h}); %#ok<NASGU>
  total_m = total_m + m;
end;

% allocate all at once to avoid reshaping iteratively
tmp_data = []; %#ok<NASGU>  This is necessary as the command is now wrapped in an if/else
if args.single
    tmp_data = zeros(mSize, total_m,'single');
else
    tmp_data = zeros(mSize, total_m);
end
total_m = 0;
    %% end contribution
for h = 1:nFiles % start looping thru the files being used.
  fprintf('\t%i',h);
  
  [m n] = size(vol{h}); %#ok<NASGU>
  
  tmp_subvol=zeros(mSize,m);
  for i = 1:m
     curvol = vol{h}(i);
     
     % Enforce mask size
%     if ~all(curvol.dim == size(maskvol))
     if ~isequal(curvol.dim,size(maskvol))
       error(['Supplied mask is not the proper size for this dataset. mask: ' maskname ' filename: ' filenames{h}]);
     end
     % Load the data from the IMG file
     [Vdata] = spm_read_vols(curvol);
     if args.single
       Vdata = single(Vdata);
     end
     
     tmp_subvol(1:mSize,i) = Vdata(mask);
     
  end
  
  % Reshape the data to be Voxels X Time
    %%%%%%%%%%%%%%%%%%%%%%
    %sylvains contribution
    %%%%%%%%%%%%%%%%%%%%%%
    tmp_data(1:mSize,total_m+1:total_m+m) = tmp_subvol;
    total_m = total_m + m;
    clear tmp_subvol;
    %% end contribution
    
end % for h

disp(' ');

%% Store the data in the pattern structure
subj = set_mat(subj,'pattern',new_patname,tmp_data);

%% Set the masked_by field in the pattern
subj = set_objfield(subj,'pattern',new_patname,'masked_by',maskname);

%% Add the history to the pattern
hist_str = sprintf('Pattern ''%s'' created by load_spm_pattern',new_patname);
subj = add_history(subj,'pattern',new_patname,hist_str,true);

%% Add information to the new pattern's header, for future reference
subj = set_objsubfield(subj,'pattern',new_patname,'header', ...
			 'vol',vol,'ignore_absence',true);

%% Load the subject         
% This object was conceived under a tree. Store that information in
% the SUBJ structure
created.function = 'load_spm_pattern';
created.args = args;
subj = add_created(subj,'pattern',new_patname,created);
end %main function