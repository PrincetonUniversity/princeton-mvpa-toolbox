function [subj, patstem] = ebc_tutorial_adv_optimize(subj, default_params, varargin) 

% Performs averaging to increase EBC generalization performance.
%
% [SUBJ] = EBC_TUTORIAL_ADV_OPTIMIZE(SUBJ, DEFAULT_PARAMS, ...)
%
% Performs spatial and temporal filtering on a given pattern, given
% a set of default parameters for filtering window size.  Spatial
% filtering is computationally intensive when written in Matlab and
% is therefore optional; temporal filtering is mandatory. 
%
% Optionally, also returns the stem of the named pattern or pattern
% groups created; typically this is '<patname>_savg_tavg' or just
% '<patname>_tavg', depending on which optimizations were
% performed.
%
% Arguments:
%
% SUBJ is the subject structure for the experiment
%
% DEFAULT_PARAMS is the parameters structure being used in the
% experiment.
%
% USE_PATNAME (optional, default = 'epi_z') the name of the base pattern
% to be optimized.
%
% SFILTER (optional, default = true) whether or not to perform
% spatial filtering.

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

% User specified pattern to use for filtering, etc.
defaults.use_patname = '';
defaults.sfilter = true;

args = propval(varargin, defaults);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Step 4 - Optimization

% find the pattern name to be used
patname = 'epi_z';
if ~isempty(args.use_patname)
  patname = args.use_patname;
end

% perform spatial averaging if it is desired
if args.sfilter
  subj = create_spatial_avg_pat(subj, patname, 'wholebrain');
  subj = remove_object(subj, 'pattern', patname);
  patname = [patname, '_savg'];
end

% get the list of each regressor we're going to use
rnames = find_group(subj, 'regressors', 'baseregs_grp');

% loop through this list
for r = 1:numel(rnames)

  % extract the regressor name, and create from it a name for our
  % new filtered pattern
  regsname = rnames{r};
  filtname = sprintf('%s_tavg_%s',patname, regsname);  

  % Create an asymmetric box filter of size from the default parameters
  filt = ones(1, default_params.time_average_window(r));
  filt = filt./sum(filt);

  % Filter using the masks we determined earlier
  subj = apply_to_runs(subj, patname, 'movies', 'apply_filt', ...
                       'filt', filt, 'new_patname', filtname, 'maskname', regsname);
  
end

% return the stem of the new filter names
patstem = [patname, '_tavg'];
