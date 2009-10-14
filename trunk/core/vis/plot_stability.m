function [] = plot_stability(subj,raw_patname,runsname,varargin)

% Visualize the stability of your signal
%
% [] = PLOT_STABILITY(SUBJ,RAW_PATNAME,RUNSNAME, ...)
%
% Takes in an existing init'ed SUBJ structure, imports the
% raw (just motion-corrected) and the despiked data, and
% plots the mean activity (throughout the brain) over time
% for both.
%
% RAW_PATNAME = the SUBJ object name for the raw (just
% motion-corrected) data.
%
% PROC_PATNAME (optional, default = []). By default, it will
% assume you don't have a processed version of your data
% (e.g. despiked or detrended, or both!). But if you do feed
% in a PROC_PATNAME, it'll plot that on top, to see how the
% preprocessing changes things.
%
% ZSCORE_BOTH (optional, default = false). If true, it will
% zscore both raw and processed data, to make sure they're
% plotted on the same scale.
%
% blue = the RAW (just motion-corrected) data
%
% green = the PROC = processed pattern
%
% red = RUNS

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

defaults.proc_patname = [];
defaults.zscore_both = true;
args = propval(varargin,defaults);

runs = get_mat(subj,'selector',runsname);
nRuns = max(runs);
nTimepoints = length(runs);

id = subj.header.id;

raw = get_mat(subj,'pattern',raw_patname);

if args.zscore_both
  % zscore it so that it's all on the same scale, if we choose
  % to plot PROC on top
  dispf('Zscoring entire %s for plotting purposes',raw_patname)
  raw = zscore(raw')';
end

maskave = nan(1,nTimepoints);
for t=1:nTimepoints
  maskave(t) = mean(raw(:,t));
end

figure
plot(maskave)
xlabel('Timepoints (TRs)')
ylabel('Mean activity across brain')
titlef( sprintf('%s - %s - mean activity over time', ...
                subj.header.id, raw_patname) )

% scale the runs values so that they overlay
maskave_range = max(maskave) - min(maskave);
runs_plot = (runs/max(runs) * maskave_range) + min(maskave);
hold on
plot(runs_plot,'r')

if ~isempty(args.proc_patname)

  % also read in the processed version of the data, for
  % comparison
  proc = get_mat(subj,'pattern',args.proc_patname);

  if args.zscore_both
    dispf('Zscoring entire %s for plotting purposes', args.proc_patname)
    proc = zscore(proc')';
  end
  
  maskave_proc = nan(1,nTimepoints);
  for t=1:nTimepoints
    maskave_proc(t) = mean(proc(:,t));
  end

  hold on
  plot(maskave_proc,'g')

  % replace the title to include the PROC_PATNAME
  titlef( sprintf('%s - %s - %s - mean activity over time', ...
                  subj.header.id, raw_patname, args.proc_patname) )
end



