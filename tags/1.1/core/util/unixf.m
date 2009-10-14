function [s,m] = unixf(varargin)
% A shortcut to unix(sprintf(...))

if islogical(varargin{1}) & varargin{1}
  varargin = varargin(2:end);
  
  cmd = sprintf(varargin{:});
  dispf('unixf: %s', cmd);
end 

if nargout == 0
  unix(sprintf(varargin{:}));
else
  [s,m] = unix(sprintf(varargin{:}));
end

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
