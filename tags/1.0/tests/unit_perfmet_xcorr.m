function [errmsgs warnmsgs] = test_perfmet_xcorr(varargin)

% USAGE :[ERRMSGS WARNMSGS] = TEST_(type)
% 
% This is a script that tests the cross correlation performance metric.
%
% INPUT ARGUMENTS:
%
% STDOUT (optional, default = true) If true, prints errors and
% warnings to screen as they occur.
%
% OUTPUT ARGUMENTS: 
%
% ERRMSGS = cell array holding the error strings
% describing any tests that failed. If this is empty,
% that's a good thing
%
% WARNMSGS = cell array, like ERRMSGS, of tests that didn't pass
% and didn't fail (e.g. because they weren't run)

defaults.stdout = true;
args = propval(varargin, defaults);

errmsgs = {};
warnmsgs = {};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% negative tests: invalid parameter testing

try
  perfmet_xcorr([], rand(5,5));
  perfmet_xcorr(rand(5,5), []);
  err('doesnt detect missing parameters');
end
try
  perfmet_xcorr(NaN(1,5), rand(1,5));
  perfmet_xcorr(rand(1,5), NaN(1,5));
  err('doesnt detect NaN inputs');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% gracefully handle pathological input

t = 'Empty datasets';
try
  
  perfmet = perfmet_xcorr(rand(1, 0), rand(1,0));

  if ~isnan(perfmet.perf)
    err(sprintf('%s - returns real perf for 0 timepoints', t));
  end
  
catch
  err(sprintf('%s - unexpected error: \n**\n%s\n**\n', t, lasterr));
end

t = 'All zeros';
try

  X = zeros(100, 1);
  Y = zeros(100, 1);
  
  perfmet = perfmet_xcorr(X',Y');
  
  if ~isnan(perfmet.perf)approx(perfmet.perf, r(2), tol)
    err(t)
  end 
  
catch
  err(sprintf('%s - unexpected error: \n**\n%s\n**\n', t, lasterr));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% standard tests

tol = 1e-15;

t = 'Random correlation';
try

  X = normrnd(0, 50, [100,1]);
  Y = normrnd(0, 50, [100,1]);
  
  perfmet = perfmet_xcorr(X',Y');
  r = corrcoef(X,Y);
  
  if ~approx(perfmet.perf, r(2), tol)
    err(sprintf('%s - %g vs %g',t, perfmet.perf, r(2)));    
  end 
  
catch
  err(sprintf('%s - unexpected error: \n**\n%s\n**\n', t, lasterr));
end

t = 'Absolute correlation';
try

  X = rand(100,1);
  
  perfmet = perfmet_xcorr(X',X');
  r = corrcoef(X,X);
  
  if ~approx(perfmet.perf, r(2), tol)
    err(sprintf('%s - %g vs %g',t, perfmet.perf, r(2)));    
  end 
  
catch
  err(sprintf('%s - unexpected error: \n**\n%s\n**\n', t, lasterr));
end

% ======================================================================
% testing helper functions

fprintf('%s: All tests completed.\n\t %d failures, %d warnings.\n', ...
        mfilename, numel(errmsgs), numel(warnmsgs));

function out = approx(a, b, tolerance)

if abs(a - b) < tolerance
  out = true;
else
  out = false;
end

end

function err(testmsg) 

e = sprintf('Test failed: %s\n', testmsg);
errmsgs{end+1} = e;

if (args.stdout)
  fprintf(e);
end

end

function warn(warnmsg)

w = sprintf('Warning: %s\n', warnmsg);
warnmsgs{end+1} = w;

if (args.stdout)
  fprintf(w);
end

end

end

