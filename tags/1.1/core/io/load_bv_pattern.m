function [subj] = load_bv_pattern(subj,new_patname,maskname,filenames,varargin)

% Loads a BrainVoyager .vtc pattern using the MVPA toolbox
%
% [SUBJ] = LOAD_BV_PATTERN(SUBJ,NEW_PATNAME,MASKNAME,FILENAMES,VARARGIN)
%
% Adds the following objects:
% - pattern object called NEW_PATNAME masked by MASKNAME
%
% In order to understand how to use this function, you'll
% need to run through the Multi-Voxel Pattern Analysis
% (MVPA) toolbox tutorial available at:
%
%   http://www.csbmb.princeton.edu/mvpa/
%
% Instead of using LOAD_AFNI_PATTERN, just call this instead
% in the same way. See the help in LOAD_AFNI_PATTERN for
% more details.
%
% This requires the bv2mat library written by Sylvain
% Takerkart and Ben Singer, available at:
%
%   http://www.csbmb.princeton.edu/mvpa/ebc/bv2mat.tar.gz
%
% Though it could be easily tweaked to use the EBC's
% READVTC function, discussed here:
%
%   http://ebc.lrdc.pitt.edu/discuss/read.php?4,24
%
% e.g. to load in ./my_bv_vtc_file.vtc, assuming that you already
% have a SUBJ structure with a mask called 'wholevol':
%
%   subj = load_bv_pattern(subj,'bv_data','wholevol','my_bv_vtc_file');
%
% or, to load in and concatenate multiple .vtc files
% together into a single pattern:
%
%   vtc_files = {'subject1_hi_s1_3DMC_SCSAI2_LTR_TAL.vtc','subject1_hi_s2_3DMC_SCSAI2_LTR_TAL.vtc'};
%   subj = load_bv_pattern(subj,'bv_data','wholevol',vtc_files);
%
% SINGLE (optional, default = false). If true, will store the data
% as singles, rather than doubles, to save memory. This
% could cause problems later, because some functions can
% only use doubles.
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
% 
% The Princeton MVPA toolbox is available free and
% unsupported to those who might find it useful. We do not
% take any responsibility whatsoever for any problems that
% you have related to the use of the MVPA toolbox.


defaults.single = false;
args = propval(varargin,defaults);

% Load the mask
maskvol = get_mat(subj,'mask',maskname);
mDims   = size(maskvol);
maskidx    = find(maskvol);

% check mask isn't empty
if isempty(maskidx)
  error('Empty mask passed to load_bv_pattern()');
end

% Initialize the data structure
subj = init_object(subj,'pattern',new_patname);

if ischar(filenames)
  filenames = {filenames};
end

nFiles = length(filenames);

% check that all the .vtc files exist in the current directory
for f=1:nFiles
  if ~exist(filenames{f},'file')
    error('One or more of your .vtc files don''t exist in the current directory');
  end
end

disp( sprintf('Starting to load BV pattern from %i VTC files',nFiles) );

% concat_data serves a similar role to tmp_data in
% LOAD_AFNI_PATTERN, except that in LOAD_AFNI_PATTERN, we're able
% to use BrikInfo to figure out in advance how big our matrix
% should be so that we can pre-initialize it to the right size
%
% Because we don't know how to tell the size of a .vtc file's
% contents without reading it in, we're just going to concat each
% file that you load in onto the back of the last one
concat_data = [];

% we're going to store all the vtc header information in one place
all_vtcs = {};

for h = 1:nFiles
  fprintf('\t%i',h);

  cur_filename = filenames{h};
  
  % if it doesn't have a .vtc extension, add one
  if ~strcmp(cur_filename(end-3:end),'.vtc')
    cur_filename = sprintf('%s.vtc',cur_filename);
  end
    
  % Load the data from the VTC file
  vtc = bv_readvtc(cur_filename);
  
  % the VTC data seems to get read in as [time x y z], so let's
  % just move time to the 4th dimension, where it belongs
  vtc.data = permute(vtc.data,[2 3 4 1]);

  Vdata = vtc.data;
  
  % remove the vtc.data field, since we don't need it any more
  vtc = rmfield(vtc,'data');
  
  % store as singles if specified
  if args.single
    Vdata = single(Vdata);
  end
  
  % Ensure that the mask dimensions match the data
  vDims = size(Vdata);
  if ~isequal(vDims(1:3),mDims(1:3))
    error('Mask dimensions do not match data');
  end
          
  % Reshape the data to be Voxels X Time
  Vdata = reshape(Vdata,prod(vDims(1:3)), vDims(4));
  
  % add Vdata onto the end of concat_data
  concat_data = [concat_data Vdata(maskidx,:)];
  
  clear Vdata
  
  all_vtcs{end+1} = vtc;
  
end % for h

% no support for/equivalent of the LOAD_AFNI_PATTERN SUB_BRIKS
% optional argument

disp(' ');

% Store the data in the pattern structure
subj = set_mat(subj,'pattern',new_patname,concat_data);

% Set the masked_by field in the pattern
subj = set_objfield(subj,'pattern',new_patname,'masked_by',maskname);

% Add the history to the pattern
hist_str = sprintf('Pattern ''%s'' created by load_bv_pattern',new_patname);
subj = add_history(subj,'pattern',new_patname,hist_str,true);

% Add information to the new pattern's header, for future reference
subj = set_objsubfield(subj,'pattern',new_patname,'header', ...
			 'vtc_heads',all_vtcs,'ignore_absence',true);
subj = set_objsubfield(subj,'pattern',new_patname,'header', ...
			 'vtc_filenames',filenames,'ignore_absence',true);

% This object was conceived under a tree. Store that information in
% the SUBJ structure
created.function = 'load_vtc_pattern';
created.args = args;
subj = add_created(subj,'pattern',new_patname,created);



