function [pval actual_val null_vals] = wavestrapper_results(results, varargin)

% Calculates significance of onoff metric using wavestrapping.
%
% [PVAL ACTUAL_VAL NULL_VALS] = WAVESTRAPPER_RESULTS(RESULTS, ...)
%
% The idea is that you feed in your RESULTS structure
% (containing some kind of classifier output that varies
% over time, like free recall), and it will scramble the
% classifier values multiple times to create a null
% distribution, which you can use to test the
% significance of your actual (real) classifier outputs.
%
% Operates on all the iterations in RESULTS together, by
% concatenating the ACTS from each iteration into one long
% nConds x nTestTimepoints matrix. Then, it feeds these ACTS
% into the Polyn-o-matic wavestrapper (uses wavelet
% decomposition/recomposition to generate multiple scrambled
% versions of ACTS). For each scrambled ACTS, it calculates
% the onoff metric (correlating each classifier output with
% each regressors row, subtracting the mean off-diagonal
% from the mean on-diagonal). Then it sorts the onoff
% metric values, and figures out what rank in this
% distribution your actual value would be (one-tailed),
% from which you can easily calculate a p-value.
%
% See WAVELET_SCRAMBLE_MULTI.M for more information on the
% wavelet scrambling, and ONOFF_METRIC.M for more
% information on assessing how good your classifier/label
% correlations are.
%
% Based on the procedure reported in Polyn et al (2005,
% Science), based on Bullmore et al (2004). See
% TutorialClass on the MVPA wiki for more info.
%
% PVAL = value from 0 to 1, where 0 is most
% significant. [This may need fine-tuning, since you
% shouldn't really get a p-value of 0...]
%
% ACTUAL_VAL = the onoff metric value calculated for your
% actual ACTS.
%
% NULL_VALS = the vector of onoff metric values calculated
% from the shuffled versions of the data, that make up your
% null distribution.
%
% NSHUFFLES (optional, default = 1000). Number of times to
% shuffle to create the null distribution.
%
% PERFMET_NAME (optional, default = 0). By default it
% assumes that you only have a single PERFMET, and that it's
% PERFMET_XCORR. If you have multiple performance metrics,
% and you want to specify which one to use, change this to
% e.g. 'perfmet_maxclass_ignore_rest'.

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

defaults.nshuffles = 1000;
defaults.perfmet_name = '';
args = propval(varargin, defaults);

% ACTS and REGS will be nConds x nTotalTestTimepoints
[acts regs] = concatenate_acts_regs(results, args);

% SHUFACTS will be nConds x nTotalTestTimepoints x nShuffles
shufacts = create_null_distribution(acts, args.nshuffles);

%%%%%
% compute the onoff goodness values for the real and for the
% shuffled ACTS

% first, figure out the correlation between each condition
% in ACTS and each condition in DESIREDS
%
% ACTUAL_CC_CORRS = nConds x nConds
actual_cc_corrs = compute_acts_desireds_corrs(acts, regs);
for n=1:args.nshuffles
  cur_shufacts = shufacts(:,:,n);
  % NULL_CC_CORRS = nConds x nConds
  null_cc_corrs = compute_acts_desireds_corrs(cur_shufacts, regs);
  % NULL_CC_CORRS_MULTI = nConds x nConds x nShuffles. This
  % stores the onoff matrix for each shuffled version of the
  % data.
  null_cc_corrs_multi(:,:,n) = null_cc_corrs;
end % n nShuffles
  
% now compare on-diagonals to off-diagonals
actual_val = onoff_metric(actual_cc_corrs);
for n=1:args.nshuffles
  null_vals(n) = onoff_metric(null_cc_corrs_multi(:,:,n));
end % n nShuffles

% finally, compute the p value for the actual, relative to the
% null distribution
pval = compute_pval_1tailed(actual_val, null_vals);




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [shufacts] = create_null_distribution(acts, nShuffles)

[nConds nTotalTestTimepoints] = size(acts);

% Levels, in a wavelet decomposition, refers to the
% successive application of the wavelet, to the signal. It
% looks like the matlab function wmaxlev will take in a
% signal and a wavelet name and tell you the maximum
% number you should use for a decomposition.  It says for a
% 1-d signal this is usually 5.
%
% So each time you apply the wavelet and get two sets of
% coefficients --- approximation and detail coefficients ---
% and then you save the detail coefficients and apply the
% wavelet again to the approximation coefficients.  (you can
% look at wavedec in matlab help)"
lvls = 5;

dispf('Beginning generation of %i shuffled ACTS', nShuffles);

% we need to create nShuffles * nConds, because we want a
% new pretend classifier output for each condition for each
% time we shuffle
%
% nShuffles*nConds x nTotalTestTimepoints
shufacts_2d = wavelet_scramble_multi(acts, 'db4', lvls, nShuffles*nConds);

% now, we need to reshape it from nShuffles*nConds x
% nTotalTestTimepoints to being nConds x
% nTotalTestTimepoints x nShuffles
%
% i tried using RESHAPE, but it screwed up the ordering, so
% it seemed easier to do it by hand
%
% shufacts = reshape(shufacts, [nConds, nTotalTestTimepoints, nShuffles]);
%
% create a long vector that looks like this [1 2
% ... nConds 1 2 ... nConds 1 2 ... nConds ...]
conds_idx = repmat(1:nConds, 1, nShuffles);
% preinitalize shufacts into the shape we want
shufacts = nan(nConds, nTotalTestTimepoints, nShuffles);
% put each condition's worth of data into the appropriate
% layer of the 3d matrix
for c=1:nConds
  cur_cond = find(conds_idx==c);
  shufacts(c,:,:) = shufacts_2d(cur_cond, :)';
end % nConds*nShuffles



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [corrs] = compute_acts_desireds_corrs(acts,regs)

% Calculates every pairwise correlation between rows in ACTS
% (nConds x nTimepoints) and rows in REGS (also nConds x
% nTimepoints).
%
% CORRS (acts nConds x regs nConds). Stores the pairwise
% ACTS-REGS correlations.


if ~compare_size(acts,regs)
  error('ACTS and REGS must be equal sizes')
end

[nConds nTimepoints] = size(acts);

% nConds (acts) x nConds(regs) matrix of correlations
corrs = nan(nConds, nConds);

for a=1:nConds % loop over rows in ACTS
  
  cur_acts = acts(a,:);
  
  for r=1:nConds % loop over rows in REGS
  
    cur_regs = regs(r,:);
    
    try
      % compute_xcorr requires both its arguments to be
      % column vectors
      cur_corr = compute_xcorr(cur_regs', cur_acts');
    catch
      % pdist requires both its arguments to be row vectors
      cur_corr = 1-pdist([cur_regs; cur_acts],'correlation');
    end

    % store it in our acts nConds x regs nConds matrix of
    % pairwise correlations between ACTS/REGS rows
    corrs(a,r) = cur_corr;
    
  end % r nConds
end % a nConds



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [allacts allregs] = concatenate_acts_regs(results, args)

% Concatenate each iteration's ACTS and PERFMET.DESIREDS
% into big matrices.


nIterations = length(results.iterations);

allacts = [];
allregs = [];

for i=1:nIterations
  cur_acts = results.iterations(i).acts;
  allacts = [allacts cur_acts];
  
  % deal with the possibility that there are multiple
  % PERFMETs in this RESULTS struct, and the user wants to
  % specify which one
  if args.perfmet_name
    perfmet_no = get_perfmet_called(results,args.perfmet_name);
    cur_regs = results.iterations(i).perfmet{perfmet_no}.desireds;
  else
    cur_regs = results.iterations(i).perfmet.desireds;
  end
  
  if isempty(cur_regs)
    continue
  end
  
  [isbool isrest isover] = check_1ofn_regressors(cur_regs);

  if size(cur_regs,1)==1
    % if there's only one row, then it's probably a
    % DESIREDS vector that can be converted into a
    % standard nConds x nTimepoints matrix
    cur_regs = ind2vec_robust(cur_regs);
  end
  
  if isbool & ~isover
  else
    warning('This scripts hasn''t been tested for non-1-of-n regressors')
  end
  
  allregs = [allregs cur_regs];  
  
end % i nIterations



