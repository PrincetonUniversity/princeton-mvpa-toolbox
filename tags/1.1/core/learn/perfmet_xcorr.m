function [perfmet] = perfmet_xcorr(acts,targs,scratchpad,varargin)

% Correlates the acts with the targets
%
% [PERFMET] = PERFMET_XCORR(ACTS,TARGS,SCRATCHPAD,...)
%
% Correlates each condition vector in ACTS with each
% condition vector in TARGS - that's the 'CORRECTS'
%
% Outputs a NaN GUESSES matrix.
%
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

if ~exist('scratchpad','var')
  scratchpad = [];
end

defaults.ignore_1ofn = true;
args = propval(varargin,defaults);

sanity_check(acts,targs,scratchpad,args);

nConds = size(targs,1);
[nUnits nTimepoints] = size(acts);

corrects = [];

if (isempty(acts)) | (isempty(targs))
  perf = NaN;
  desireds = targs; 
else
  
  for c=1:nConds
    curact = acts(c,:);
    curtarg = targs(c,:);

    % check for invalid input first
    if std(curact) == 0
      warning('Cannot compute correlation: std(curact) = 0');
      corrects(c) = NaN;
    elseif std(curtarg) == 0
      warning('Cannot compute correlation: std(curtarg) = 0');
      corrects(c) = NaN;
    else
      
      cur_condcorr = 1-pdist([curact; curtarg],'correlation');
      corrects(c) = cur_condcorr(1);
    end
    
  end % c

  desireds = targs;
end

guesses = NaN;

% Need to be able to gracefully deal with the possibility
% that all the timepoints from this run were excluded
% (i.e. the xval timepoints for this run are all
% 0s). Sanity_check will warn if this is the case
if isempty(corrects)
  perf = NaN;
else
  corrects_no_nan = corrects(find(~isnan(corrects)));
  
  perf = mean(corrects_no_nan);
end

perfmet.guesses    = guesses;
perfmet.desireds   = desireds;
perfmet.corrects   = corrects;
perfmet.perf       = perf;
perfmet.scratchpad = [];


%initialising the *msgs cell arrays
errmsgs = {}; 
warnmsgs = {};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [] = sanity_check(acts,targs,scratchpad,args)

if isempty(acts) & ~isempty(targs)
  error('You have an acts matrix but no targs matrix');
end
if isempty(targs) & ~isempty(acts)
  error('You have a targs matrix but no acts matrix');
end

if isempty(acts) & isempty(targs)
  warning('Acts and targs are empty for this iteration');
end

if ~compare_size(acts,targs)
  error('Can''t calculate performance if acts and targs are different sizes');
end

if any(isnan(acts)) | any(isnan(targs))
  error('Inputs cannot be NaN');
end

