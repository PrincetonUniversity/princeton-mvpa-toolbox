function [] = view_montage(subj,anat_type,anat_name,funct_type,funct_name,varargin)

% View your data in a montage of slices
%
% [] = VIEW_MONTAGE(SUBJ,ANAT_TYPE,ANAT_NAME,FUNCT_TYPE,FUNCT_NAME,...)
%
% Uses Keith Schneider's MR_MONTAGE to do the main
% displaying work.
%
% ANAT_NAME = the name of the pattern that you want to
% use as your anatomical (background). This pattern is
% required to be an nVox x 1 pattern.
%
% ANAT_TYPE = 'pattern or mask'. Required
%
% FUNCT_TYPE = 'pattern' or 'mask'. If FUNCT_NAME is empty,
% this can be too.
%
% FUNCT_NAME = the name of the pattern to use as an
% overlay (nVox x nTimepoints). Will create a bunch of
% subplots for each slice.
%
% If FUNCT_NAME is empty, then no functional will be
% overlaid.
%
% SLICES (optional, default = []). By default, will
% display all slices. Feed in a vector of slice indices
% if you only want to display a subset of slices.
%
% ORIENTATION (optional, default = 'axial'). Not
% implemented yet. In the future, it would be nice to be
% able to specify coronal or sagittal, perhaps by
% permuting the order of the dimensions before calling
% the montage scripts.
%
% THRESH (optional, default = NaN). By default, will show
% all the voxels in the functmask. Set this thresh to
% non-zero to only include voxels GREATER_THAN THRESH.
%
% GREATER_THAN (optional, default = false). Toggle to
% false if you want to threshhold voxels BELOW the THRESH.
%
% REMOVE_SINGLETONS (optional, default = 0). Calls
% MAKE_CLUST with CLUST_SIZE of REMOVE_SINGLETONS
%
% INVISIBLE (optional, default = false). If true,
% sets the figure to be *invisible*. This is extremely
% useful when combined with the SAVE_PNG argument if you're
% viewing the montages over a slow X11/SSH - rather than
% waiting for the figure to draw, you can just grab the
% .png file and view it locally.
%
% PRINTFIG(optional, default = ''). If set to a string,
% will use PRINTFIG.M to save the figure to a .png file.
%
% SMOOTH_ADJ_LIST (optional, default = []). Set this to
% an ADJ_LIST cell array (as created by
% CREATE_ADJ_LIST.M) to smooth before removing singletons
% or thresholding - not implemented, because we don't
% have a smoothing function that runs directly on
% functional volumes

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

defaults.slices = [];
defaults.thresh = NaN;
defaults.greater_than = false;
defaults.remove_singletons = 0;
defaults.orientation = 'axial';
defaults.invisible = false;
defaults.printfig = '';
% defaults.smooth_adj_list = [];
args = propval(varargin,defaults);

if ~exist('funct_type')
  funct_type = '';
end
if ~exist('funct_name')
  funct_name = '';
end

% they might not want to specify a functional to
% display. that's ok
%
% but specifying a name without a type is not ok
if isempty(funct_type) & ~isempty(funct_name)
  error('Need to specify whether %s is a pattern or mask',funct_name);
end

% just warn them if they specify a type but no name
if ~isempty(funct_type) & isempty(funct_name)
    warning('You''ve specified a funct type but no name');
end

switch anat_type
 case 'pattern'
  anatpat = get_mat(subj,'pattern',anat_name);
  anatmask_name = get_objfield(subj,'pattern',anat_name,'masked_by');
  anatvol = get_mat(subj,'mask',anatmask_name);
  anatmask = anatvol;
  anatvol(find(anatmask)) = anatpat;
 case 'mask'
  anatmask = get_mat(subj,'mask',anat_name);
  anatvol = anatmask;
  
 otherwise
  error('Anat_type must be pattern or mask');
end

% if there's no functional to display, then we're pretty
% much done
if isempty(funct_name)
  % haven't added the propval + title arguments to mr_montage 
  mr_montage(anatvol,args.slices);
  disp('No functional to display')
  return
end

sanity_check(args);

% if we're displaying a pattern, we need to get the pattern,
% get its mask, and turn the pattern into a volume
if strcmp(funct_type,'pattern')
  functpat = get_mat(subj,'pattern',funct_name);
  
  if size(functpat,2)>1
    warning('Throwing away all but the first timepoint from the functpat');
    functpat = functpat(:,1);
  end

  functmask_name = get_objfield(subj,'pattern',funct_name,'masked_by');
  functmask = get_mat(subj,'mask',functmask_name);
  functvol = functmask;
  functvol(find(functmask)) = functpat;

  % things are easy if we're just displaying a mask
else
  functvol = get_mat(subj,'mask',funct_name);
  functmask = functvol;

end

ttext = sprintf('%s - %s, %s',subj.header.id,anat_name,funct_name);

if ~isnan(args.thresh)
  if args.greater_than
    functmask(find(functvol<args.thresh)) = 0;
    threshtext = sprintf('>%f',args.thresh);
  else
    functmask(find(functvol>=args.thresh)) = 0;
    threshtext = sprintf('<%f',args.thresh);
  end
  if ~length(find(functmask))
    warning('No functional voxels made it through the mask');
  end
  functmask(find(functmask)) = 1;

  ttext = sprintf('%s, %s',ttext,threshtext);
end    

if args.remove_singletons
  rs_args.do_plot = false;
  functmask = make_clust(functmask,args.remove_singletons,rs_args);
  ttext = sprintf('%s, clustsize = %i',ttext,args.remove_singletons);
end

if args.invisible
  curfig = figure('Visible','off')
  dispf('Setting figure %i to be invisible',curfig);
else
  curfig = figure;
end

mr_fmontage(anatvol,functvol,functmask, ...
            'slices',args.slices, ...
            'title',ttext);

if ~isempty(args.printfig)
  % printfig(args.printfig)
  dispf('saveas %s',args.printfig);
  saveas(curfig,args.printfig,'png');
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [] = sanity_check(args)

if ( ...
    ~isnumeric(args.slices) | ...
    (~isvector(args.slices) & ~isempty(args.slices)) ...
    )
  error('Slices has to be a numeric vector');
end

% would like to also check that slices is within the allowed
% range etc., but we can't do that till later, when we know
% the size of the volume

if ~isnumeric(args.thresh)
  error('Threshold has to be numeric');
end

if ~strcmp(args.orientation,'axial')
  error('Orientations besides axial haven''t been implemented yet');
end
  
