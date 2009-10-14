function [perfmet] = perfmet_template(acts,targs,scratchpad,args)

% This is the template perfmet function for creating your own
%
% [PERFMET] = PERFMET_TEMPLATE(ACTS,TARGS,SCRATCHPAD,ARGS)

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


if ~compare_size(acts,targs)
  error('Can''t calculate performance if acts and targs are different sizes');
end

[nUnits nTimepoints] = size(acts);

% Calculate your performance PERF here, using the acts, targs and
% args however you like

% This just returns a random performance value
perf = rand(1);

% Be sure to save your working
perfmet.perf       = perf;
perfmet.scratchpad = [];
