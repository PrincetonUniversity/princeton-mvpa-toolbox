function [subj new_patname] = zscore_runs(subj,patname,selname,varargin)

% Zscore each voxel, separately for each run
%
% [SUBJ NEW_PATNAME] = ZSCORE_RUNS(SUBJ,PATNAME,SELNAME,...)
%
% For each voxel in each run, subtract the mean activity and scale
% so that the variance is 1.
%
% Adds the following objects:
% - pattern object
%
% This function creates a new patterns object (PATNAME + '_z') to store
% the z_scored timeseries.
%
% % RUNS_SELNAME should consist of a vector with each TR labelled by
% its run number. For instance, an extremely brief experiment with
% 4 runs, with 5 TRs in each run, would look like this:
%    [1 1 1 1 1 2 2 2 2 2 3 3 3 3 3 4 4 4 4 4]
% This runs vector should not include any zeros.
%
% There is currently no functionality for ignoring any TRs, even
% rest. This is deliberate. Some of the functions that get run after
% this allow you to ignore rest TRs without actually deleting them
% from your data.
%
% USE_MVPA_VER (optional, default = false). If true, this will use
% the MVPA zscoring function (ZSCORE_MVPA.M) rather than the Stats
% toolbox ZSCORE.M

% This is part of the Princeton MVPA toolbox, released under the
% GPL. See http://www.csbmb.princeton.edu/mvpa for more
% information.


if nargin<3
  error('Need 3 arguments');
end

defaults.use_mvpa_ver = false;
args = propval(varargin,defaults);

new_patname = sprintf('%s_z',patname);

pat = get_mat(subj,'pattern',patname);
sel = get_mat(subj,'selector',selname);

sanity_check(pat,sel);

if ~args.use_mvpa_ver
  zscore_funct_hand = str2func('zscore');
  disp( sprintf('Beginning zscore_runs (Mathworks) - max_runs = %i',max(sel)) );
else
  zscore_funct_hand = str2func('zscore_mvpa');
  disp( sprintf('Beginning zscore_runs (home-made) - max_runs = %i',max(sel)) );
end

pat = zscore_runs_logic(pat,sel,zscore_funct_hand);

subj = duplicate_object(subj,'pattern',patname,new_patname);
subj = set_mat(subj,'pattern',new_patname,pat);

zhist = sprintf('Pattern ''%s'' created by zscore_runs',new_patname);
subj = add_history(subj,'pattern',new_patname,zhist,true);

created.function = 'zscore_runs';
created.use_mvpa_ver = args.use_mvpa_ver;
created.patname = patname;
created.selname = selname;
subj = add_created(subj,'pattern',new_patname,created);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [pat] = zscore_runs_logic(pat,sel,zscore_funct_hand)

% max(sel) amounts to the maximum number of runs there could
% be. any values in the runs selector that are <= 0 will be ignored
% by the for loop. won't mind if you're lacking a particular run in
% the middle either
for r = 1:max(sel)
  fprintf('\t%i',r)

  % These are all the timepoints that appear in this run
  foundRuns = find(sel==r);
  
  % The double-transpose is necessary, because the zscore function
  % doesn't allow you to specify which dimension to zscore along
  pat(:,foundRuns) = zscore_funct_hand(pat(:,foundRuns)')';
  
end % for runs

disp(' ');




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [] = sanity_check(pat,sel)

if length(find(sel==0))
  error('Your runs vector contains zeros');
end

if ~isrow(sel)
  error('Your runs vector should be a row vector');
end

if size(pat,2) ~= length(sel)
  error('You have different numbers of timepoints in your patterns and runs');
end

if length(find(diff(sel)<0))
  error('Your runs seem to be jumbled');
end

if length(find(diff(sel)>1))
  warning('You seem to be missing a run in the middle');
end
