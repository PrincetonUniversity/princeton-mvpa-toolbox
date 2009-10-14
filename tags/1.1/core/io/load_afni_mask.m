function [subj] = load_afni_mask(subj,new_maskname,filename,varargin)

% Loads an AFNI dataset into the subj structure as a mask
%
% [SUBJ] = LOAD_AFNI_MASK(SUBJ,NEW_MASKNAME,FILENAME,...)
%
% Adds the following objects:
% - mask object called NEW_MASKNAME
%
% SUB_BRIK (optional, default = []). By default, you'll get
% an error if you try and load in a brik with multiple
% sub-briks. If your brik has no sub-briks, this will load
% that Set this to a number if your brik file contains
% multiple sub-briks. Note: this indexing starts from *1*,
% not from zero, so you should feed in numbers that are one
% greater than their corresponding sub-brik numbers in afni
%
% LOGICAL (optional, default = false). By default, loads in
% the values as doubles. Set this to true if you want to
% load them in as logicals.
%
% FILTER_BY (optional, default = []). By default,
% LOAD_AFNI_MASK treats all non-zero values as included in
% the mask. If you only want to include particular non-zero
% values, then feed in a scalar here, e.g. 2, then
% LOAD_AFNI_MASK will treat all the 2s as part of the mask,
% and ignore anything else.
%
% xxx there should be a way to threshold statmap briks as they get
% loaded in to turn them directly into masks, otherwise they would
% first have to be loaded in as statmap patterns. this should
% use a call to the guts of create_threshold_mask which would have
% to be factored out

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


defaults.sub_brik = [];
defaults.logical = false;
defaults.filter_by = [];
args = propval(varargin,defaults);

% Initialize the new mask
subj = init_object(subj,'mask',new_maskname);

[err,V,AFNIheads,ErrMessage]= BrikLoad(filename);
% Check for errors
if err == 1
  error(sprintf('error in BrikLoad -%s',ErrMessage));
end

switch length(args.filter_by)
 case 0
  % don't filter at all
 case 1
  V = V == args.filter_by;
 otherwise
  error('Can only filter by a single value')
end % filter_by

if ~isempty(args.sub_brik)
  if ~isscalar(args.sub_brik) || ~isint(args.sub_brik)
    error('ARGS.SUB_BRIK must be a single integer');
  end
end

if ndims(V)<=3
  if ~isempty(args.sub_brik)
    warning(['Your sub_brik index will be ignored - only one 3D' ...
	     ' volume in the brik']);
  end
else
  if ~isempty(args.sub_brik)
    V = V(:,:,:,args.sub_brik);
  else
    error('Trying to load in a 4D dataset as a mask');
  end
end

if ~length(find(V))
  error( sprintf('There were no voxels active in the %s.BRIK mask',filename) );
end

% Does this consist of solely ones and zeros?
if length(find(V)) ~= (length(find(V==0))+length(find(V==1)))
  disp( sprintf('Setting all non-zero values in the %s.BRIK mask to one',filename) );
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
			 'afni_heads',AFNIheads,'ignore_absence',true);
subj = set_objsubfield(subj,'mask',new_maskname,'header', ...
			 'afni_filename',filename,'ignore_absence',true);

% Record how this mask was created
created.function = 'load_afni_mask';
subj = add_created(subj,'mask',new_maskname,created);

