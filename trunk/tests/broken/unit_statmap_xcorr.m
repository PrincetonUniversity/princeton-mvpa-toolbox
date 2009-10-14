function [errmsgs warnmsgs] = unit_statmap_xcorr(varargin)

% [ERRMSGS WARNMSGS] = UNIT_STATMAP_XCORR(type)
% 
% This is a script that tests the cross correlation statmap.
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
% prepare test subject

subj = init_subj('test', 'test');
subj = initset_object(subj, 'mask', 'all', ones(5,5,4));
subj = initset_object(subj, 'pattern', 'epi', rand(100, 100), ...
                      'masked_by','all');
subj = initset_object(subj, 'regressors', 'conds', rand(5,100));

runsmat = ones(1, 100);
runsmat(50:end) = 2;

subj = initset_object(subj, 'selector', 'runs', runsmat);

subj = create_xvalid_indices(subj, 'runs');

subj_bak = subj;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% only works on valid regressors:

% requires row vectors
try
  subj = statmap_xcorr(subj, 'epi', 'conds', 'runs_xval_1', ...
                       'epi_xcorr', []);
  err('should not work on non row vector regressors');

catch
  subj = separate_regressors(subj, 'conds');
  try 
    subj = statmap_xcorr(subj, 'epi', 'conds_1', 'runs_xval_1', ...
                         'epi_xcorr', []);    
  catch
    err(sprintf('regstesting - unexpected error: %s', lasterr));
  end  
end

% pdist fails on constants:
try
  subj = initset_object(subj, 'regressors', 'bad', zeros(1,100));
  subj = statmap_xcorr(subj, 'epi', 'bad', 'runs_xval_1', ...
                       'epi_xcorr', []);
  err('should fail if constant regressor is given');
end
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% check correlation values
tol = 1e-14;

r1 = rand(1, 100);
r2 = rand(1, 100);

subj = initset_object(subj, 'selector', 'sel', ones(1,100));

t = 'Correlation test - random';
try    
  
  subj = initset_object(subj, 'regressors', 'rand', r1);
  subj = initset_object(subj, 'pattern', 'randpat', r2);
  
  subj = statmap_xcorr(subj, 'randpat', 'rand', 'sel', ...
                       'randpat_xcorr', []);
  
  randpat_xcorr = get_mat(subj, 'pattern', 'randpat_xcorr');
  
  r = corrcoef(r1, r2);
  
  if ~approx(randpat_xcorr, r(2), tol)
    err(sprintf('%s - %g vs %g',t, randpat_xcorr, r(2)));    
  end 

catch
  err(sprintf('%s - unexpected error: \n**\n%s\n**\n', t, lasterr));
end

t = 'Correlation test - absolute correlation';
try    
  
  subj = set_mat(subj, 'pattern', 'randpat', r1);
  
  subj = statmap_xcorr(subj, 'randpat', 'rand', 'sel', ...
                       'randpat_xcorr2', []);
  
  randpat_xcorr = get_mat(subj, 'pattern', 'randpat_xcorr2');
  
  r = corrcoef(r1, r1);
 
  if ~approx(randpat_xcorr, r(2), tol)
    err(sprintf('%s - %g vs %g',t, randpat_xcorr, r(2)));    
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

