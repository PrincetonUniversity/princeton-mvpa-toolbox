function [subj] = feature_select(subj,data_patin,regsname,selsgroup,varargin)

% No-peeking feature selection
%
% [SUBJ] = FEATURE_SELECT(SUBJ,DATA_PATIN,REGSNAME,SELSGROUP,...)
%
% Calls a statmap generation function multiple times, using
% a different selector each time. This creates a group of
% statmaps, which are then thresholded to create a group of
% boolean masks, ready for use in no-peeking
% cross-validation classification.
%
% Adds the following objects:
% - pattern group of statmaps called NEW_MAP_PATNAME
% - mask group based on the statmaps called
%   sprintf('%s%i',NEW_MASKSTEM,THRESH)
%
% DATA_PATIN should be the name of the pattern object that
% contains voxel (or other feature) values that you want to
% create a mask of. If DATA_PATIN is a group_name, then this
% will use a different member of the group for each
% iteration.
%
% REGSNAME should be a binary nConds x nTimepoints 1-of-n matrix
%
% SELSGROUP should be the name of a selectors group, such as
% created by create_xvalid_indices
%
% For each iteration: call the ANOVA on the DATA_PATIN data,
% which will produce a statmap, employing only the TRs
% labelled with a 1 in the selector for that iteration
%
% NEW_MAP_PATNAME (optional, default = DATA_PATIN +
% STRIPPED_NAME). The name of the new statmap pattern group
% to be created. By default, this will be 'anova' if
% STATMAP_FUNCT = 'statmap_anova' etc.
%
% NEW_MASKSTEM (optional, default = DATA_PATIN +
% 'anovathresh'). The name of the new thresholded boolean
% mask group to be created from the ANOVA statmap. You'll
% need to create multiple mask groups if you want to try out
% multiple thresholds, so adding the threshold to the name
% is a good idea
%
% THRESH (optional, default = 0.05). Voxels that don't meet
% this criterion value don't get included in the boolean
% mask that gets created from the ANOVA statmap. If THRESH =
% [], the thresholding doesn't get run
%
% STATMAP_FUNCT (optional, default = 'statmap_anova'). Feed
% in a function name and this will create a function handle
% to that and use it to create the statmaps instead of
% statmap_anova
%
% STATMAP_ARG (optional, default = []). If you're using an
% alternative voxel selection method, you can feed it a
% single argument through this
%
% Need to implement a THRESH_TYPE argument (for p vs F
% values), which would also set the toggle differently xxx
%
% e.g. subj = feature_select( ...
%         subj,'epi_z','conds','runs_nmo_xvalid','thresh',0.001)

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


defaults.new_map_patname = '';
defaults.new_maskstem = sprintf('%s_thresh',data_patin);
defaults.thresh = 0.05;
defaults.statmap_funct = 'statmap_anova';
defaults.statmap_arg = struct([]);
args = propval(varargin,defaults);

if isempty(args.new_map_patname)
  % get the name of the function being run, e.g. 'statmap_anova' -> 'anova'
  stripped_name = strrep(args.statmap_funct,'statmap_','');
  args.new_map_patname = sprintf('%s_%s',data_patin,stripped_name);
end

% append the thresh to the end of the name
args.new_maskstem = sprintf( ...
    '%s%s',args.new_maskstem,num2str(args.thresh));

% Find the selectors within the specified group
selnames = find_group(subj,'selector',selsgroup);
nIterations = length(selnames);

[data_patnames isgroup] = find_group_single(subj,'pattern',data_patin,'repmat_times',nIterations);

if length(data_patnames) ~= length(selnames)
  error('Different number of patterns and selectors');
end

if nIterations == 0
  error('No selectors in %s group',selsgroup);
end

% % this warning used to be here to remind people of the
% % existence of peek_feature_select, but since there are good
% % reasons why one might want to have just one selector
% % without using peek_feature_select, i took it out
% if nIterations == 1
%   warning('You''re only calling the anova once because you have one selector - use peek_feature_select instead?');
% end

if ~ischar(args.statmap_funct)
  error('The statmap function name has to be a string');
end

disp( sprintf('Starting %i %s iterations',nIterations,args.statmap_funct) );

for n=1:nIterations
  fprintf('  %i',n);
  
  % Get the pattern for this iteration
  cur_data_patname = data_patnames{n};
  
  % Get the selector name for this iteration
  cur_selname = selnames{n};

  % Name the new statmap pattern and thresholded mask that will be created
  cur_maskname = sprintf('%s_%i',args.new_maskstem,n);
  cur_map_patname = sprintf('%s_%i',args.new_map_patname,n);

  % if a pattern with the same name already exists, it
  % will trigger an error later in init_object, but we
  % want to catch it here to save running the entire
  % statmap first
  if exist_object(subj,'pattern',cur_map_patname)
    error('A pattern called %s already exists',cur_map_patname);
  end
  
  if ~isempty(args.statmap_arg) && ~isstruct(args.statmap_arg)
    warning('Statmap_arg is supposed to be a struct');
  end
  
  % Add the current iteration number to the extra_arg, just in case
  % it's useful
  args.statmap_arg(1).cur_iteration = n;

  % Create a handle for the statmap function handle and then run it
  % to generate the statmaps
  statmap_fh = str2func(args.statmap_funct);
  subj = statmap_fh(subj,cur_data_patname,regsname,cur_selname,cur_map_patname,args.statmap_arg);
  subj = set_objfield(subj,'pattern',cur_map_patname,'group_name',args.new_map_patname);

  if ~isempty(args.thresh)
    % Now, create a new thresholded binary mask from the p-values
    % statmap pattern returned by the anova
    subj = create_thresh_mask(subj,cur_map_patname,cur_maskname,args.thresh);
    subj = set_objfield(subj,'mask',cur_maskname,'group_name',args.new_maskstem);
  end
  
end % i nIterations

disp(' ');
disp( sprintf('Pattern statmap group ''%s'' and mask group ''%s'' created by feature_select', ...
	      args.new_map_patname,args.new_maskstem) );


    





