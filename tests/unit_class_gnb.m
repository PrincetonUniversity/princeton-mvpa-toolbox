function [errmsgs warnmsgs] = unit_class_gnb(varargin)

% USAGE :[ERRMSGS WARNMSGS] = TEST_(...)
% 
% This is a script that tests 
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Prepare test subject



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Negative unit tests (program should fail)

try
  % TODO: Do something that should cause an error and halt
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Positive unit tests (program should not fail)

% ------------------------------------------------------------------------

t = 'Simple normal-generated data';
try
  
  nConds = 5;
  scale = [10 2];
 
  priorblocks = [1000 1000 500 1000 1000]';
  prior = (priorblocks + 1) ./ (sum(priorblocks) + nConds);  

  % randomly generate regressor
  regs = [];
  for k = 1:nConds
    regs = horzcat(regs, ones(1, priorblocks(k))*k);
  end    

  regs = shuffle(regs);
  
  mu = (1:nConds) * scale(1);
  sigma = randn(1,nConds) * scale(2);

  % make 1-of-n-regressors
  regsmat = ind2vec_robust(regs);

  % start with only one voxel
  pat = NaN(1, cols(regsmat));

  % generate each datapoint of the pattern according to one of the
  % distributions 
  for i = 1:numel(regs)
    pat(i) = randn * sigma(regs(i)) + mu(regs(i));
  end

%  hist(pat, 150);
  class_args.uniform_prior = true;
  scratch = train_gnb(pat, regsmat, class_args, []);

  diff = abs(prior - scratch.prior);
  differs = any(diff > 0);
  if differs ~= class_args.uniform_prior
    err('%s - priors were not learned correctly\n', t);
  end  
  
  % the parameters found by train_gnb should be close to the originals
  for k = 1:nConds
    if ~approx(mu(k), scratch.mu(k), 0.2)
      err('%s - cluster %g has inaccurate mean %g (%g)\n', t, k, ...
          mu(k), scratch.mu(k));
    end    

    if ~approx(abs(sigma(k)), scratch.sigma(k), 0.2)
      warn('%s - cluster %g has inaccurate variance %g (%g)\n', t, k, ...
          sigma(k), scratch.sigma(k));
    end    

  end
  
  % now test simple prediction on 100 points:
  for k = 1:nConds
    
    nTest = 100;
    
    % generate data from this distribution
    pat = randn(1, nTest) * sigma(k) + mu(k);
    
    % get predictions
    acts = test_gnb(pat, regsmat, scratch);
    
    [a i] = max(acts);

    % count up the 
    score = numel(find(i == k)) / nTest;
    
    if score < 0.9
      err('%s - prediction accuracy only %g on cluster %g\n', t, ...
          score, k);
    end
    
  end
        
catch
  err('%s - unexpected error: \n**\n%s\n**\n', t, lasterr);
end

% ------------------------------------------------------------------------

t = 'Complex random data';

try
  
  nVox = 10;
  nConds = 5;
  scale = [0.5 2];
  
  mu = randn(nVox, nConds) * scale(1);
  sigma = randn(nVox, nConds) * scale(2);
    
  pat = NaN(nVox, cols(regs));

  % generate each datapoint of the pattern according to one of the
  % distributions 
  for i = 1:numel(regs)
    pat(:,i) = (randn(nVox,1) .* sigma(:,regs(i))) + mu(:,regs(i));
  end

%  compare against backprop?
%  class_args.nHidden = 0;
%  scratch = train_bp(pat, regsmat, class_args, []);

% train up the GNB  
  scratch = train_gnb(pat, regsmat, {}, []);
  
%   % check distances between means, etc.
   ref_dists = pdist(mu');
   new_dists = pdist(scratch.mu');
%   squareform(ref_dists)
%   squareform(new_dists)

   diff = abs(new_dists - ref_dists)./abs(ref_dists);
   if any(diff > 0.1)
     err('%s - means have moved by more than 10 percent\n', t);
   end

  % now test simple prediction on 100 points:
  for k = 1:nConds
        
    % generate data from this distribution
    pat = (randn(nVox, nTest) .* repmat(sigma(:,k), 1, nTest)) + ...
          repmat(mu(:,k), 1, nTest);
    
    % get predictions
    acts = test_gnb(pat, regsmat, scratch);
%    acts = test_bp(pat, regsmat(:, 1:cols(pat)), scratch);
    
    [a i] = max(acts);

    % count up the 
    score = numel(find(i == k)) / nTest;
    
    if score < 0.9
      err('%s - prediction accuracy only %g on cluster %g\n', t, ...
          score, k);
    end
  end
      
catch
  err('%s - unexpected error: \n**\n%s\n**\n', t, lasterr);
end

% ------------------------------------------------------------------------
t = 'Prior test';

try

catch
  err('%s - unexpected error: \n**\n%s\n**\n', t, lasterr);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Standard Testing Utility Functions 

% output the status after all tests are completed
fprintf('%s: All tests completed.\n\t %d failures, %d warnings.\n', ...
        mfilename, numel(errmsgs), numel(warnmsgs));

% compute approximate equality
function out = approx(a, b, tolerance)

if abs(a - b) < tolerance
  out = true;
else
  out = false;
end

end

% customized error function: supports printf syntax
function err(varargin) 

testmsg = sprintf(varargin{:});

e = sprintf('Test failed: %s\n', testmsg);
errmsgs{end+1} = e;

if (args.stdout)
  fprintf(e);
end

end

% customized warning function: supports printf syntax
function warn(varargin)

warnmsg = sprintf(varargin{:});

w = sprintf('Warning: %s\n', warnmsg);
warnmsgs{end+1} = w;

if (args.stdout)
  fprintf(w);
end

end

end


