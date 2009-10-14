function [subj] = detrend_runs(subj,patname,selname,varargin)

% [SUBJ] = DETREND_RUNS(SUBJ,PATNAME,SELNAME,...)
%
% For each voxel in each run, detrend_runs removes trends
% according to the order of the specified polynomial 
% i.e. 1 = linear, 2 = linear + quadratic, ...	
%
% Adds the following objects:
% - pattern object
%
% This function creates a new patterns object (PATNAME + '_d') to store
% the detrended timeseries.
%
% RUNS_SELNAME should consist of a vector with each TR labelled by
% its run number. For instance, an extremely brief experiment with
% 4 runs, with 5 TRs in each run, would look like this:
%    [1 1 1 1 1 2 2 2 2 2 3 3 3 3 3 4 4 4 4 4]
% This runs vector should not include any zeros.
%
% ORDER (optional, default = 2)
% specify order of polynomials to remove trends 
%
% NEW_PATNAME (optional, default = sprintf(%s_d',patname))
%
% 15-01-08 written by Thomas Wolbers (based on zscore_runs.m provided by the MVPA
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


if nargin < 3
  error('Need 3 arguments');
end

defaults.order = 2;	% remove linear and quadratic trends
defaults.new_patname = sprintf('%s_d',patname);
args = propval(varargin,defaults);

pat = get_mat(subj,'pattern',patname);
sel = get_mat(subj,'selector',selname);
 
sanity_check(pat,sel);

pat = remove_trends(pat,sel,args.order);

subj = duplicate_object(subj,'pattern',patname,args.new_patname);
subj = set_mat(subj,'pattern',args.new_patname,pat);

zhist = sprintf('Pattern ''%s'' created by detrend_runs',args.new_patname);
subj  = add_history(subj,'pattern',args.new_patname,zhist,true);

created.function = 'detrend_runs';
created.patname = patname;
created.selname = selname;
subj = add_created(subj,'pattern',args.new_patname,created);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [pat] = remove_trends(pat,sel,order)

% max(sel) amounts to the maximum number of runs there could
% be. Any values in the runs selector that are <= 0 will be ignored
% by the for loop. won't mind if you're lacking a particular run in
% the middle either

nRuns = max(sel);

for r = 1:nRuns
  progress(r,nRuns);

  this_run   = sel==r; % select current run
  active_trs = find(this_run == 1);
  
  % ----- fit polynomials and remove corresponding trends
  for i = 1: size(pat,1) 
	p = polyfit(1:length(active_trs),pat(i,active_trs),order);
	pat(i,active_trs) = pat(i,active_trs) - polyval(p,1:length(active_trs));
  end
    
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
