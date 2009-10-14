function [perfmet] = perfmet_xcorr_onoff(acts,targs,scratchpad,args)

% Calculates the onoff metric, as per Polyn et al (2005).
%
% That is, it runs pairwise correlations between every
% condition's ACTS and every condition's TARGS, and
% subtracts the mean of the same-condition correlations from
% the mean of the different-condition
% correlations.
%
% xxx maybe instead of being called PERFMET_XCORR_ONOFF, it
% should just be called PERFMET_ONOFF, and allow you to
% specify the PDIST distance metric to use???
%
% [PERFMET] = PERFMET_XCORR_ONOFF(ACTS,TARGS,SCRATCHPAD,ARGS)

% This is part of the Princeton MVPA toolbox, released under the
% GPL. See http://www.csbmb.princeton.edu/mvpa for more
% information.


if ~compare_size(acts,targs)
  error('Can''t calculate performance if acts and targs are different sizes');
end

[nConds nTimepoints] = size(acts);

% hardcoded for now
distmet = 'correlation';

pwise_corrs = nan(nConds,nConds);

if isempty(acts)
  % don't bother doing anything. leave PWISE_CORRS as NaNs
  perfmet.perf = NaN;
  return
end


% create the pairwise correlations matrix
for a=1:nConds % acts
  for t=1:nConds % targs
    curacts = acts(a,:);
    curtargs = targs(t,:);
    % for some reason, if the std is too small (or
    % something), pdist fails fatally, so be robust to that
    try
      pwise_corrs(a,t) = 1-pdist([curacts; curtargs],distmet);
    catch
      pwise_corrs = NaN;
    end
  end % t
end % a

[perf on_diags off_diags] = onoff(pwise_corrs);

% Be sure to save your working
perfmet.perf       = perf;
perfmet.scratchpad.pwise_corrs = pwise_corrs;
perfmet.scratchpad.on_diags = on_diags;
perfmet.scratchpad.off_diags = off_diags;
perfmet.scratchpad.distmet = distmet;
