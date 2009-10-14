function [val x] = getpropval(x, property, default)
% GETPROPVAL - In-line propval.
%
% Usage:
%
% [VALUE VARARGIN] = GETPROPVAL(VARARGIN, PROPERTY, DEFAULT)
%
% GETPROPVAL is for obtaining property-value pairs from a VARARGIN
% cell array without requiring the strict PROPVAL format. This
% looks for the first instance of PROPERTY, and, if found, takes
% the next argument in VARARGIN as VALUE, strips them both, and
% then returns the remaining VARARGIN. If PROPERTY is not found,
% then VALUE is equal to DEFAULT.

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

if nargin==2
  default = [];
end

val = default;

if ~iscell(x)
  x = {x};
end

for i = 1:numel(x)
  
  if ischar(x{i})
    if strcmp(x{i}, property)
      val = x{i+1};
      
      x = x([1:(i-1) (i+2):end]);
      
      return;
    end
  end
  
end

