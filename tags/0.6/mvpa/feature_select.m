function [subj] = feature_select(subj,data_patname,regsname,selsgroup,varargin)

% No-peeking feature selection
%
% [SUBJ] = NOPEEK_FEATURE_SELECT(SUBJ,DATA_PATNAME,REGSNAME,SELSGROUP,...)
%
% Calls a statmap generation function multiple times, using a
% different selector each time. This creates a group of statmaps,
% which are then thresholded to create a group of boolean masks, ready
% for use in no-peeking cross-validation classification.
%
% Adds the following objects:
% - pattern group of statmaps called NEW_MAP_PATNAME
% - mask group based on the statmaps called NEW_MASKSTEM
%
% DATA_PATNAME should contain the voxel (or other feature) values
% that you want to create a mask of
%
% REGSNAME should be a binary nConds x nTimepoints 1-of-n matrix
%
% SELSGROUP should be the name of a selectors group, such as
% created by create_xvalid_indices
%
% For each iteration: call the ANOVA on the DATA_PATNAME data, which
% will produce a statmap, employing only the TRs labelled with a 1
% in the selector for that iteration
%
% NEW_MAP_PATNAME (optional, default = DATA_PATNAME + '_anovamap'). The
% name of the new statmap pattern group to be created
%
% NEW_MASKSTEM (optional, default = DATA_PATNAME +
% 'anovathresh'). The name of the new thresholded boolean mask
% group to be created from the ANOVA statmap. You'll need to create
% multiple mask groups if you want to try out multiple thresholds,
% so adding the threshold to the name is a good idea
%
% THRESH (optional, default = 0.05). Voxels that don't meet
% this criterion value don't get included in the boolean mask that
% gets created from the ANOVA statmap
%
% STATMAP_FUNCT (optional, default = 'statmap_anova'). Feed in a
% function name and this will create a function handle to that and
% use it to create the statmaps instead of statmap_anova
%
% STATMAP_ARG (optional, default = []). If you're using an
% alternative voxel selection method, you can feed it a single
% argument through this
%
% Need to implement a THRESH_TYPE argument (for p vs F values), which would also
% set the toggle differently xxx
%
% e.g. subj = feature_select( ...
%         subj,'epi_z','conds','runs_nmo_xvalid','thresh',0.001)

% This is part of the Princeton MVPA toolbox, released under the
% GPL. See http://www.csbmb.princeton.edu/mvpa for more
% information.


defaults.new_map_patname = sprintf('%s_statmap',data_patname);
defaults.new_maskstem = sprintf('%s_thresh',data_patname);
defaults.thresh = 0.05;
defaults.statmap_funct = 'statmap_anova';
defaults.statmap_arg = [];
args = propval(varargin,defaults);

% Find the selectors within the specified group
selsnames = find_group(subj,'selector',selsgroup);
nIterations = length(selsnames);

if nIterations == 0
  error('No selectors in that group');
end
if nIterations == 1
  warning('You''re only going to call the anova once because you only have one selector - use peek_feature_select instead?');
end

if ~ischar(args.statmap_funct)
  error('The statmap function name has to be a string');
end

disp( sprintf('Starting %i anova iterations',nIterations) );

for n=1:nIterations
  fprintf('\t%i',n);
  
  % Get the selector for this iteration
  cur_selname = selsnames{n};    
  sels = get_mat(subj,'selector',cur_selname);  

  % Name the new statmap pattern and thresholded mask that will be created
  cur_maskname = sprintf('%s_%i',args.new_maskstem,n);
  cur_patname = sprintf('%s_%i',args.new_map_patname,n);
  
  % Create a handle for the statmap function handle and then run it
  % to generate the statmaps
  statmap_fh = str2func(args.statmap_funct);
  subj = statmap_fh(subj,data_patname,regsname,cur_selname,cur_patname,args.statmap_arg);
  subj = set_objfield(subj,'pattern',cur_patname,'group_name',args.new_map_patname);

  % Now, create a new thresholded binary mask from the p-values
  % statmap pattern returned by the anova
  subj = create_thresh_mask(subj,cur_patname,cur_maskname,args.thresh);
  subj = set_objfield(subj,'mask',cur_maskname,'group_name',args.new_maskstem);
  
end % i nIterations

disp(' ');
disp( sprintf('Pattern statmap group ''%s'' and mask group ''%s'' created by feature_select', ...
	      args.new_map_patname,args.new_maskstem) );


    





