function [errmsgs warnmsgs] = unit_separate_regressors(varargin)

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


% ======================================================================
% testing helper functions

fprintf('%s: All tests completed.\n\t %d errors, %d warnings.\n', ...
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

