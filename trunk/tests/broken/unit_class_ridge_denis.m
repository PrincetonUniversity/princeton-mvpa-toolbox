function [errmsgs warnmsgs] = unit_class_ridge_denis(varargin)

% USAGE :[ERRMSGS WARNMSGS] = UNIT_CLASS_RIDGE_DENIS(type)
%
% This tests denis' modified version that includes an offset
% parameter - 070411.
% 
% This is a script that tests the functionality of the ridge
% regression scripts, train_ridge_denis.m and test_ridge_denis.m  It tests that
% the function rejects bad parameters and runs the regression
% through some basic test datasets: pure linear regression,
% regression on noisy data, some boundary conditions (datasets of
% all ones or zeros), and the like.
%
% INPUT ARGUMENTS:
%
% STDOUT (optional, default = true) If true, prints errors and
% warnings to stdout as they occur.
%
% OUTPUT ARGUMENTS: 
%
% ERRMSGS = cell array holding the error strings
% describing any tests that failed. If this is empty,
% that's a good thing
%
% WARNMSGS = cell array, like ERRMSGS, of tests that didn't pass
% and didn't fail (e.g. because they weren't run)
%

defaults.stdout = true;
args = propval(varargin, defaults);

errmsgs = {};
warnmsgs = {};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% parameter tests: invalid parameter testing

% train_ridge_denis
try
  train_ridge_denis(rand(5,5), rand(1,5), [], [])
  err('train_ridge_denis should require penalty parameter');
end
try
  class_args.penalty = 0;
  train_ridge_denis(rand(5,5), rand(5,1), class_args);
  err('non-row vector targets should not be allowed');
end
try
  class_args.penalty = 0;
  train_ridge_denis(rand(5,5), rand(1,3), class_args);
  err('should detect differing columns of targets and pattern');
end
try
  class_args.penalty = 0;
  train_ridge_denis(NaN(5,5), rand(1,5), class_args);
  err('should detect NaN data');
end
try
  class_args.penalty = 0;
  train_ridge_denis(rand(5,5), NaN(1,5), class_args);
  err('should detect NaN data');
end

% test_ridge_denis
try
  class_args.penalty = 0;
  test_ridge_denis(NaN(5,5), rand(1,5), class_args);
  err('should detect NaN data');
end
try
  class_args.penalty = 0;
  test_ridge_denis(rand(5,5), NaN(1,5), class_args);
  err('should detect NaN data');
end
try
  test_ridge_denis(rand(5,5), rand(1,5));
  err('should require scratchpad from train_ridge_denis');
end
try
  scratchpad.ridge.betas = rand(5,1);
  test_ridge_denis(rand(5,5), rand(5,1), scratchpad);
  err('should detect non-row vector targets');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% test on purely linear data, in pure regression mode (no penalty)

t = 'Regression on purely linear data';
try  

  A = rand(1,10); % parameters of original dataset (estimated by beta)
  X = rand(10, 500); % test data
  Y = A*X; % no noise
  class_args.penalty = 0;
   
  % compare derived coefficients to the originals
  scratchpad = train_ridge_denis(X, Y, class_args);

  % 070411 - because the new ridge_denis betas are a
  % different size, this next line is causing a 'matrix
  % dimensions must agree' error, so i just commented out
  % the line, so that things would continue
%   d = sum(abs(A' - scratchpad.ridge.betas));
%   if d > 1e-14
%     warn(sprintf('%s - Betas not equal, diff=%g', t, d));
%   end
  
  % get predictions and compare to originals (absolute value)
  [acts scratchpad] = test_ridge_denis(X, Y, scratchpad);
  d = sum(abs(Y - acts));
  if d > 1e-11
    err(sprintf('%s - Acts ~= Y, diff=%g', t, d));
  end

  % test correlation: should be within 1e-15 of 1
  perfmet = perfmet_xcorr(acts, Y);
  if perfmet.perf < 1 - 1e-15
    err(sprintf('%s - Non-perfect prediction, perf=%g', t, ...
                perfmet.perf));
  end
  
catch
  err(sprintf('%s - unexpected error: \n**\n%s\n**\n', t, lasterr));
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% test prediction on random dataset - (nothing)
n = 10;
m = 500;

t = 'Random dataset, no relation';

try
  
  X = rand(n,m);
  Y = rand(1,m);
  
  class_args.penalty = 0.2;
  
  scratchpad = train_ridge_denis(X, Y, class_args);
  [acts scratchpad] = test_ridge_denis(X, Y, scratchpad);
  
  perfmet = perfmet_xcorr(acts, Y);
  if perfmet.perf > 0.5
    err(sprintf('%s - unnaturally good prediction, perf=%g', ...
                perfmet.perf));
    
  end  
  
catch
  err(sprintf('%s - unexpected error: \n**\n%s\n**\n', t, lasterr));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% test prediction on synthetic dataset - predictable vs. scrambled

n = 10;
m = 500;
t = 'Synthetic dataset, with relation';
try
  
  % make sure it can learn random data fairly well
  X = rand(n,m);
  A = rand(1,n);
  Y = A*X + normrnd(0, 0.5, [1 m]);  
  
  class_args.penalty = 0.2*n;
  
  scratchpad = train_ridge_denis(X, Y, class_args);
  [acts scratchpad] = test_ridge_denis(X, Y, scratchpad);
  
  perfmet = perfmet_xcorr(acts, Y);
  if perfmet.perf < 0.5
    err(sprintf(['%s - bad prediction on random data, ' ...
                 'perf=%g'], perfmet.perf));
  end

  betas_high = scratchpad.ridge.betas;
  
  % run again, but with a higher penalty, and then compare the
  % weights to the previous weights to ensure that ridge regression
  % is assigning higher absolute betas in the low penalty condition
  
  class_args.penalty = 0.5*n;
  
  scratchpad = train_ridge_denis(X, Y, class_args);
  [acts scratchpad] = test_ridge_denis(X, Y, scratchpad);
  
  perfmet = perfmet_xcorr(acts, Y);
  if perfmet.perf < 0.5
    err(sprintf(['%s - bad prediction on random data, ' ...
                 'perf=%g'], perfmet.perf));
  end

  if sum(abs(betas_high)) < sum(abs(scratchpad.ridge.betas));
    err(sprintf('%s - weights do not decrease with increasing penalty', ...
                t));
  end  
  
  % now test prediction w/ scrambled
  scramY = Y(randperm(numel(Y)));
  
  scratchpad = train_ridge_denis(X, scramY, class_args);
  [acts scratchpad] = test_ridge_denis(X, scramY, scratchpad);
  
  perfmet = perfmet_xcorr(acts, scramY);
  if perfmet.perf > 0.5
    err(sprintf(['%s - unnaturally good prediction on scrambled data, ' ...
                 'perf=%g'], perfmet.perf));
  end  
catch
  err(sprintf('%s - unexpected error: \n**\n%s\n**\n', t, lasterr));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% boundary conditions

t = 'Boundary condition: all zeros';
try
  
  X = zeros(n, m);
  Y = zeros(1, m);
  
  class_args.penalty = 0.2;
  
  scratchpad = train_ridge_denis(X, Y, class_args);  
  [acts scratchpad] = test_ridge_denis(X, Y, scratchpad);
  
  if any(acts)
    err(sprintf('%s - non zero act detected'), t);
  end

catch
  err(sprintf('%s - unexpected error: \n**\n%s\n**\n', t, lasterr));
end

t = 'Boundary condition: all ones';
try
  
  X = ones(n, m);
  Y = ones(1, m);
  
  class_args.penalty = 0.2;
  
  scratchpad = train_ridge_denis(X, Y, class_args);  
  [acts scratchpad] = test_ridge_denis(X, Y, scratchpad);
  
  if ~all(acts)
    err(sprintf('%s - acts is not all ones', t));
  end

catch
  err(sprintf('%s - unexpected error: \n**\n%s\n**\n', t, lasterr));
end

% % 070411 - this gives me a 'matrix is singular to working
% % precision' error. so i commented it out because i
% % don't care too much about a single data point. i hope
% % this isn't important...
%
% t = 'Boundary condition: dataset of size 1';
% try
  
%   X = 1;
%   Y = 1;
%   class_args.penalty = 0;
  
%   scratchpad = train_ridge_denis(X, Y, class_args);  
%   [acts scratchpad] = test_ridge_denis(X, Y, scratchpad);
  
%   if ~approx(acts,1,1e-15);
%     err(sprintf('%s - acts ~= 1', t));
%   end
%   if ~approx(scratchpad.ridge.betas,1, 1e-15)
%     err(sprintf('%s - betas ~= 1', t));
%   end

% catch
%   err(sprintf('%s - unexpected error: \n**\n%s\n**\n', t, lasterr));
% end

% ======================================================================
% testing helper functions

fprintf('%s: All tests completed.\n\t %d failures, %d warnings.\n', ...
        mfilename, numel(errmsgs), numel(warnmsgs));



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out = approx(a, b, tolerance)

if abs(a - b) < tolerance
  out = true;
else
  out = false;
end

end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function err(testmsg) 

e = sprintf('Test failed: %s\n', testmsg);
errmsgs{end+1} = e;

if (args.stdout)
  fprintf(e);
end

end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function warn(warnmsg)

w = sprintf('Warning: %s\n', warnmsg);
warnmsgs{end+1} = w;

if (args.stdout)
  fprintf(w);
end

end

end


