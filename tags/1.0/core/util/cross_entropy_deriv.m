function [d] = cross_entropy_deriv(code, e, x, perf, pp)

% Derivative of cross-entropy
%
% [D] = CROSS_ENTROPY_DERIV(CODE, E, X, PERF, PP)
%
% See CROSS_ENTROPY.M

% This is part of the Princeton MVPA toolbox, released under the
% GPL. See http://www.csbmb.princeton.edu/mvpa for more
% information.

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

e_was_double = isa(e,'double');
if e_was_double, e = {e}; end

switch code
  case 'e'
    [rows,cols] = size(e);
    d = cell(rows,cols);
    for i=1:rows
      for j=1:cols
        if ~isempty( e{i,j} )
          t       = pp.targets; %pattern targets
          y       = t - e{i,j}; %estimations
          y(y==0) = eps;        %safeguards
          y(y==1) = 1-eps;
          d{i,j}  = t ./ y - (1-t) ./ (1-y); %Gradient dE/dy= -t/y,where E=CrossEntropy
        end
      end
   end
   if e_was_double, d = d{1}; end

  case 'x'
    d = zeros( size(x) );

  otherwise
    error('unknown argument')
end
