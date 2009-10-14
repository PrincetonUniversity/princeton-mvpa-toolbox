function [perfmet] = perfmet_template(acts,targs,args)

% This is the template perfmet function for creating your own
%
% [PERFMET] = PERFMET_TEMPLATE(ACTS,TARGS,ARGS)


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
