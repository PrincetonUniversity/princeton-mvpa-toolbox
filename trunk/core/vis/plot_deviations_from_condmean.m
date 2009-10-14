function [deviations meanpats mean_deviations_per_cond] = plot_deviations_from_condmean(subj,patname,regsname,runsname,varargin)

% [DEVIATIONS MEANPATS MEAN_DEVIATIONS_PER_COND] = PLOT_DEVIATIONS_FROM_CONDMEAN(SUBJ, PATNAME, REGSNAME, RUNSNAME, ...)
%
% Designed for debugging classification performance. It just runs
% simple tests to look at Euclidean distance between timepoints within
% a condition etc. Takes the mean of each condition, and
% then for each timepoint runs a 1-nearest neighbor classifier to see
% which of these condition means that timepoint is closest to.
%
% REGSNAME must point to a binary regressors matrix with no
% overactive TRs. It can have rest - those timepoints will
% be ignored.
%
% MEANPATS (nVox x nConds) = each 'timepoint' is an average
% of all the timepoints from that condition. i think this is
% the same as running AVERAGE_OBJECT on with
% condlabels. This is used for various computations
% below. Excludes the current timepoint from the average.
%
% DEVIATIONS (nConds x nActives) = the distance between each
% timepoint and (the mean of all timepoints of that
% condition). 'Actives' here means that one of the
% conditions in the REGSNAME matrix is 1, and all others are
% 0. Values for rest TRs and inactive conditions will be NaNs.
%
% MEAN_DEVIATIONS_PER_COND (1 x nConds) = shows, for each
% condition, the mean deviations for all the timepoints that
% belong to it. This is useful for checking whether there's
% one particularly aberrant condition.
%
% MASKNAME (optional, default = ''). By default, uses the whole
% volume.
%
% PLOT_ALL_FIGS (optional, default = true). By default,
% plots all kinds of things. If false, will only plot the
% final deviations/desireds/corrects plot.
%
% EXTRA_REGSNAME (optional, default = ''). Plots another regressors
% matrix as well, with the same rest timepoints thrown away.
%
% See TRAIN/TEST_1NN_AVG for a classifier implementation of
% this simple 1-nearest neighbor Euclidean distance
% algorithm.


defaults.maskname = '';
defaults.extra_regsname = '';
defaults.plot_all_figs = true;
args = propval(varargin,defaults);
args_into_workspace;

if maskname
  pat = get_masked_pattern(subj,patname,maskname);
else
  pat = get_mat(subj,'pattern',patname);
end
regs = get_mat(subj,'regressors',regsname);
runs = get_mat(subj,'selector',runsname);
condnames = get_objfield(subj,'regressors',regsname,'condnames');

[isbool isrest isover] = check_1ofn_regressors(regs);
if ~isbool | isover
  error('Can''t deal with non-boolean or overactive regressors');
end

nVox = size(pat,1);
[nConds nTRs] = size(regs);
nRuns = max(runs);

% if the CONDNAMES field is empty, replace with {'1','2','3'...}
if isempty(condnames)
  condnames = cell(1,nConds);
  for c=1:nConds
    condnames{c} = sprintf('%i',c);
  end
end

% check that there are the same number of TRs per condition
nUniques = length(unique(sum(regs,2)));
if nUniques~=1
  warning('You don''t have the same number of TRs in each condition')
end

nTRsPerCond = sum(regs,2);

% mean of all the timepoints for each condition (nVox x
% nConds)
meanpats = nan(nVox,nConds);

% calculate the mean patterns for each condition
for c=1:nConds
  
  cur_cond_TRs = find(regs(c,:)==1);
  
  curpats = pat(:,cur_cond_TRs);
  
  curmeanpat = mean(curpats,2);
  meanpats(:,c) = curmeanpat;
  
end % c nConds

% gets the index of the active condition for each timepoint
regs_ind = vec2ind_inclrest(regs);

% preinitialize
deviations = nan(nConds,nTRs);
actives = zeros(1,nTRs);

% compare each timepoint to its corresponding condition-mean
for t=1:nTRs
  
  progress(t,nTRs);

  %   c = regs_ind(t);
  %   %   % if this timepoint wasn't an active condition
  %   if ~c
  %     continue
  %   end

  if regs_ind(t)~=0
    actives(t) = 1;
  end
  
  curtimepoint = pat(:,t);

  for c=1:nConds
    
    curmeanpat = meanpats(:,c);
 
    % if we're looking at the right answer, then and only
    % then do we need to subtract this pattern from the
    % canonical condmean brainstate
    %
    % (before, i was subtracting the current timepoint from
    % each of the condmeans, including when it wasn't
    % included in the first place)
    if c==regs_ind(t)
      % need to recalculate the MEANPATS to exclude this
      % timepoint from the mean
      %
      % undo the dividing by n
      curmeanpat = (curmeanpat * nTRsPerCond(c));
      % subtract out the current pattern
      curmeanpat = curmeanpat - curtimepoint;
      curmeanpat = curmeanpat / (nTRsPerCond(c)-1);
    end
    
    curdist = euclidn(curmeanpat, curtimepoint);
    deviations(c,t) = curdist;
    
  end
  
end % t nTRs
disp(' ')

actives = logical(actives);

if args.plot_all_figs
  figure, hold on
  lines_colors = lines(nConds);
  for c=1:nConds
    curcol = lines_colors(c,:);
    % plot each condition as a separate color
    plot(deviations(c,actives==1), 'o',  ...
         'MarkerEdgeColor', curcol, ...
         'MarkerFaceColor', curcol );
  end
  titlef('Deviations of each timepoint from its condition mean')
  ylabel('euclid (higher is worse)')
  legend(condnames)
end % plot all figs

mean_deviations_per_cond = nan(1,nConds);
for c=1:nConds
  cur_deviations_cond = deviations(c,:);
  mean_deviations_per_cond(c) = mean_ignore_nans(cur_deviations_cond);
end
if args.plot_all_figs
  figure
  bar(mean_deviations_per_cond)
  titlef('Mean deviations for each condition')

  figure
  plot(deviations(regs==1));
  titlef('Deviations over time (ignoring rest timepoints')

end % plot all figs

nActives = length(find(actives));
counter = 1;
corrects = [];
% these are, in effect, our simple Euclidean distance
% classifier's guesses
mins = mini(deviations);

figure
% 3 refers to the guesses/desireds/corrects triplet for each run
nSubplots = 3*nRuns;
% create e.g. [1 2 3 4; 5 6 7 8; 9 10 11 12]
plots = [];
for i=1:3
  plots = [plots; (1:nRuns) + (i-1)*nRuns];
end

for r=1:nRuns
  
  % get the timepoints from this run
  % run_timepoints = find(runs==r);
  
  cur_deviations = deviations(:, runs==r & actives==1);
  cur_guesses = mins(runs==r & actives==1);

  subplot(3,nRuns,plots(counter))
  imagesc(cur_deviations);
  xlabel('Timepoints for this run')
  ylabel('Right answer (darker is better)')
  titlef('Guesses - distance from each timepoint to every condition - run %i',r);
  colormap(hot)
  % colorbar
  counter = counter + 1;

  subplot(3,nRuns,plots(counter))
  cur_regs = regs(:,runs==r & actives==1);
  cur_regs_ind = regs_ind(runs==r & actives==1);
  imagesc(cur_regs)
  titlef('Desireds')
  colormap(hot)
  % colorbar
  counter = counter + 1;
  
  subplot(3,nRuns,plots(counter))
  cur_corrects = cur_regs_ind==cur_guesses;
  if length(cur_corrects), plot(cur_corrects), end
  ax = axis; ax([3 4]) = [-.2 1.2]; axis(ax)
  titlef('Corrects')
  % colormap(hot)
  % colorbar
  counter = counter + 1;
  axis tight
  
  corrects = [corrects cur_corrects];
  
  % dispf('Displaying run %i - press to see next',r);
  % pause

end % r nRuns

if args.extra_regsname
  extra_regs = get_mat(subj,'regressors',args.extra_regsname);
  extra_regs_norest = extra_regs(:,actives);
  figure, imagesc(extra_regs_norest);
  colormap(gray)
  titlef('%s regs without rest',args.extra_regsname);
end % extra_regsname

runs_norest = runs(actives);
figure, imagesc(runs_norest);
colormap(gray)
titlef('%s selector without rest',runsname);

dispf('%.2f% performance',mean(corrects))



