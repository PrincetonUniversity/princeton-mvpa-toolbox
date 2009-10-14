function [str] = estimate(t)
% Gives an appropriately unitized string of a duration in seconds.
%
% [STR] = ESTIMATE(T)
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
minutes = t./60;
hours = t./3600;
days = hours./24;
years = days./365;

if years > 1
  str = sprintf('%.2f yrs', years);
elseif days > 1.5
  str = sprintf('%.2f days', days);
elseif hours > 1
  str = sprintf('%.2f hr', hours);
elseif minutes > 2
  str = sprintf('%.2f min',minutes);
else
  str = sprintf('%.2f sec',t);
end
