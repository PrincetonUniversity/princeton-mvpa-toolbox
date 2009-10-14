function [subj] = hpfilter_runs(subj,patname,selname,cutoff,tr,varargin)

% Uses spm_filter.m to high-pass filter the time series of each voxel
% in each run
% Adds the following objects: - pattern object
%
% This function creates a new patterns object (PATNAME + '_hp') to store
% the filtered timeseries.
%
% FORMAT [SUBJ] = HPFILTER_RUNS(SUBJ,PATNAME,SELNAME,CUTOFF,TR,...)
%
% ----------------------------------------------------------------
% Input arguments:
%
% RUNS_SELNAME should consist of a vector with each TR labelled by
% its run number. For instance, an extremely brief experiment with
% 4 runs, with 5 TRs in each run, would look like this:
%    [1 1 1 1 1 2 2 2 2 2 3 3 3 3 3 4 4 4 4 4]
% This runs vector should not include any zeros.
%
% CUTOFF - cut-off period in seconds
%
% TR - repetition time in seconds
%
% ----------------------------------------------------------------
% Optional arguments:
% 
% NEW_PATNAME (optional, default = sprintf(%s_hp',patname))
%
% 17-01-08 written by Thomas Wolbers (based on zscore_runs.m provided by the MVPA
%	   toolbox)

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


if nargin < 5
  error('Need 5 arguments');
end

defaults.new_patname = sprintf('%s_hp',patname);
args = propval(varargin,defaults);

pat = get_mat(subj,'pattern',patname);
sel = get_mat(subj,'selector',selname);
 
sanity_check(pat,sel);

pat = hp_filter(pat,sel,cutoff,tr)';

subj = duplicate_object(subj,'pattern', patname, args.new_patname);
subj = set_mat(subj, 'pattern',args.new_patname, pat);

zhist = sprintf('Pattern ''%s'' created by hpfilter_runs',args.new_patname);
subj  = add_history(subj,'pattern',args.new_patname,zhist,true);

created.function = 'hpfilter_runs';
created.patname = patname;
created.selname = selname;
subj = add_created(subj,'pattern',args.new_patname,created);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function data = hp_filter(pat,sel,cutoff,tr)

% max(sel) amounts to the maximum number of runs there could
% be. any values in the runs selector that are <= 0 will be ignored
% by the for loop. won't mind if you're lacking a particular run in
% the middle either

nRuns = max(sel);
data  = pat';	% transposition required for spm_filter

for r = 1:nRuns
  progress(r,nRuns);
  this_run = sel==r; % select current run

  K(r).row = find(this_run == 1);
  K(r).RT  = tr;
  K(r).HParam = cutoff;

  data = spm_filter(K,data);

end

disp(' ')


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
