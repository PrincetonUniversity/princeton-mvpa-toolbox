function perf = cross_entropy(e, x, pp)

% Cross-entropy error measure
%
% [D] = CROSS_ENTROPY(CODE, E, X, PERF, PP)
%
% Feed this in with class_args to train_bp to change from the
% default mean squared error
%
% See http://www.cse.unsw.edu.au/~billw/cs9444/crossentropy.html
% for more information on what it is.
%
% Requires a derivative function too - see CROSS_ENTROPY_DERIV.M

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


if nargin < 1, error('missing arguments'), end

if ischar(e)
  switch e
    case 'version',   perf = 3.0;
    case 'deriv',     perf = 'CrossEntropyDeriv';
    case 'name',      perf = 'CrossEntropy';
    case 'pnames',    perf = { 'targets' };
    case 'pdefaults', perf = struct( 'targets', []);
    otherwise,        error('unknown argument')
  end
  return
end

if isa(e,'cell'), e = cell2mat(e); end

if isa(e,'double')
  t = pp.targets; %targets
  y = t - e;      %estimations; this depends on the definition of
                  %'e' from 'calcpref.m'
  y(y==0) = eps;  %safeguards
  y(y==1) = 1-eps;
  perf = - sum( sum( t .* log(y) + (1 - t) .* log(1 - y) ) ); %CrossEntropy definition
else
  error('performance function argument not double')
end
