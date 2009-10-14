function [subj] = zscore_runs(subj,patname,selname,varargin)

% Zscore each voxel, separately for each run
%
% [SUBJ] = ZSCORE_RUNS(SUBJ,PATNAME,SELNAME,...)
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
% RUNS_SELNAME should consist of a vector with each TR labelled by
% its run number. For instance, an extremely brief experiment with
% 4 runs, with 5 TRs in each run, would look like this:
%    [1 1 1 1 1 2 2 2 2 2 3 3 3 3 3 4 4 4 4 4]
% This runs vector should not include any zeros.
%
% ACTIVES_SELNAME (optional, default = ''). If empty string,
% then this will zscore all the timepoints in each run by
% estimating their mean and standard deviation, just as
% you'd expect.
%
%   If it contains a selector name (with a vector of
%   booleans) then it determines the mean and standard
%   deviation based on just the active timepoints, and
%   then uses those parameters to zscore all the
%   timepoints in the entire run.
%
%   This still treats each run separately.
%
%   N.B. This replaces the previous behavior for this
%   optional argument, which would only z-score the
%   active timepoints, and leave the inactive timepoints
%   untouched. This new behavior makes more sense.
%
% USE_MVPA_VER (optional, default = false). If true, this will use
% the MVPA zscoring function (ZSCORE_MVPA.M) rather than the Stats
% toolbox ZSCORE.M
%
% NEW_PATNAME (optional, default = sprintf(%s_z',patname))
%
% IGNORE_JUMBLED_RUNS (optional, default = false). As per
% CREATE_XVALID_INDICES.


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


if nargin<3
  error('Need 3 arguments');
end

defaults.use_mvpa_ver = false;
defaults.actives_selname = '';
defaults.new_patname = sprintf('%s_z',patname);
defaults.ignore_jumbled_runs = false;
args = propval(varargin,defaults);

pat = get_mat(subj,'pattern',patname);
sel = get_mat(subj,'selector',selname);
 

if ~args.use_mvpa_ver
  zscore_funct_hand = str2func('zscore');
  disp( sprintf('Beginning zscore_runs (Mathworks) - max_runs = %i',max(sel)) );
else
  zscore_funct_hand = str2func('zscore_mvpa');
  disp( sprintf('Beginning zscore_runs (home-made) - max_runs = %i',max(sel)) );
end

% this is the active selector part 
% this default active selector is the one used for the actual data.

if isempty(args.actives_selname)
  % If no actives_selname was fed in, then assume the user wants all
  % TRs to be included, and create a new all-ones actives selector
  actives = ones(size(sel));
else
  % Otherwise, use the one they specified
  actives = get_mat(subj,'selector',args.actives_selname);
end

sanity_check(pat,sel,actives,args);

if ~compare_size(actives,sel)
  error('Your actives and runs are different sizes');
end

pat = zscore_runs_logic(pat,sel,actives,zscore_funct_hand);

subj = duplicate_object(subj,'pattern',patname,args.new_patname);
subj = set_mat(subj,'pattern',args.new_patname,pat);

zhist = sprintf('Pattern ''%s'' created by zscore_runs',args.new_patname);
subj = add_history(subj,'pattern',args.new_patname,zhist,true);

created.function = mfilename;
created.use_mvpa_ver = args.use_mvpa_ver;
created.patname = patname;
created.selname = selname;
created.actives_selname = args.actives_selname;
subj = add_created(subj,'pattern',args.new_patname,created);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [pat] = zscore_runs_logic(pat,sel,actives, zscore_funct_hand)

% max(sel) amounts to the maximum number of runs there could
% be. any values in the runs selector that are <= 0 will be ignored
% by the for loop. won't mind if you're lacking a particular run in
% the middle either

filtered_sel= sel .* actives;

nRuns = max(sel);

for r = 1:nRuns
  progress(r,nRuns);

  % we're going to just create a couple of booleans
  % narrowing things down to the current run, and whether
  % those timepoints are active
  this_run = sel==r;
  actives_this_run = this_run & actives;
  
  if ~any(actives_this_run)
    warning('Ignoring run %i because all actives are zero',r)
    continue
  end
  
  % if there are any inactive timepoints in this run
  if sum(this_run)~=sum(actives_this_run)
    % then we need to figure out the mean and sd for just
    % the actives, and then use them to zscore the whole run
    
    % calc the mean and std
    mu = mean(pat(:,actives_this_run),2);
    sigma = std(pat(:,actives_this_run),[],2);
    % replicte them over the second dimension
    mu = mu(:,ones(1,sum(this_run)));
    sigma = sigma(:,ones(1,sum(this_run)));
    
    % subtract the mean and divide by the std
    pat(:,this_run) = (pat(:,this_run)-mu)./sigma;
    
  else
    % nice and simple. just zscore away the whole run
    
    % The double-transpose is necessary, because the zscore function
    % doesn't allow you to specify which dimension to zscore along
    pat(:,actives_this_run) = zscore_funct_hand(pat(:,actives_this_run)')';
  
  end % any inactive?
    
end % for runs

disp(' ')



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [] = sanity_check(pat,sel,actives,args)

if ~isint(actives)
  error('Use only integers for the active_selector');
end

if find(actives > 1 | actives < 0)
  error('Your active_selector should be binary only');   
end  
  
if length(find(sel==0))
  error('Your runs vector contains zeros');
end

if ~isrow(sel)
  error('Your runs vector should be a row vector');
end

if size(pat,2) ~= length(sel)
  error('You have different numbers of timepoints in your patterns and runs');
end

if length(find(diff(sel)<0)) & ~args.ignore_jumbled_runs
  error('Your runs seem to be jumbled');
end

if length(find(diff(sel)>1))
  warning('You seem to be missing a run in the middle');
end
