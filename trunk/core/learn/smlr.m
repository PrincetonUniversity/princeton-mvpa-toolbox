function [w, args, log_posterior, wasted, saved] = smlr(X, Y, varargin) 
% Trains a Sparse Multinomial Logistic Regression (SMLR) classifier.
%
% Usage:
%
%   [W, ARGS, LP, WASTED, SAVED] = SMLR(X, Y, ...)
%
% Fits the Sparse Multinomial Logistic Regression (SMLR) model to a
% given dataset. Multinomial Logistic Regression (MLR) stipulates that
% multinomial (multi-class) labels are generated according to the
% logistic distribution from a linear combination of per-class weights
% on each of the dimensions of the input. In other words, MLR is a
% multi-class generalization of standard logistic regression. This
% version of MLR is regularized to enforce sparsity in the solution
% using a Laplacian (L1) prior. Thus, the SMLR model performs feature
% selection in addition to classification.
%
% The implementation provided here uses an iterative optimization
% algorithm described in [1] to perform MAP estimation. A
% MEX-optimized version is provided in smlr_mex.c.  By default, the
% MEX version will be automatically used for the optimization, as it
% provides a dramatic performance boost.
%
% Inputs:
%
%   X - A N x D matrix of inputs to use to train the classifier.
%
%   Y - A N x M 'one-of-m' form binary matrix indicating the class
%         of each of the training points in X, where each data point
%         can be one of M classes.
%
% Outputs:
%
%   W - The D x M matrix of class weights that are used to generate
%     predictions. NOTE: Because the last class in a multinomial
%     distribution can be expressed as "not the others", only M-1
%     weights are actually necessary to predict M classes. However, by
%     default, we fit weights for all M classes to facilitate
%     interpretation. See below for more information.
% 
%   ARGS - The structure defining the combination of default and
%     user-specified options that determined the various optional
%     aspects of the fitting routine.
%
%   LP - The value of the log posterior at the estimated solution W.
%
%   WASTED - A vector indicating the number of 'wasted' visits by the
%     algorithm to features with weight zero, that stayed at zero
%     after optimizing, on each iteration of the optimization. Large
%     numbers of wasted visits indicates that the algorithm is
%     revisiting zero-valued weights too frequently. NOTE: this is
%     only returned if the MEX routine is not used.
%
%   SAVED - A vector indicating the number of 'saved' weights by the
%     algorithm on each round of iteration. A 'saved' weight is one
%     that was zero but set to non-zero after being optimized. NOTE:
%     this is only returned if the MEX routine is not used.
% 
% Optional Arguments:
%
%   'lambda' - The regularization constant indicating the relative
%     amount of regularization. (Default: .1)
%
%   'w_init' - A starting matrix for W. Note that W can be either D x
%     M or D x M-1 in size; in the latter case, the last column of W is
%     assumed to be zero, which is sufficient for solving an M-class problem. 
%     (Default: [])
%
%   'fit_all' - Whether or not to fit a D x M or D x M-1 matrix of
%     weights. If 'w_init' is set, then 'fit_all' is
%     irrelevant. Otherwise, W is initialized to a matrix of zeros of
%     size D x M if 'fit_all' is true, and size D x M-1
%     otherwise. (Default: true)
%
%   'constant' - Whether or not to add an additional constant feature
%     of ones to the beginning of the input X. (Default: false)
%
%   'tol' - The tolerance of the optimization, as measured in the norm
%     of the gradient of the weight matrix from one iteration to the
%     next. Smaller values mean a longer optimization, but more
%     precise results. (Default: 1e-3).
%
%   'max_iter' - Maximum number of iterations in the
%     optimization. (Default: 1e5)
%
%   'decay_rate' - The rate at which the sampling distribution for
%     zeroed weights decays towards the minimum; a lower value means
%     that zeroed weights (selected out features) are less likely to
%     be re-examined during the fitting process. (Default: 0.25)
%
%   'decay_min' - The minimum sampling probability of a zeroed weight
%     (selected out feature). If zero, weights will never be
%     reconsidered after several non-changing considerations. (Default: 0)
%
%   'mex' - Whether or not to try to use the MEX-optimized
%     version. (Default: true)
%
%   'verbose' - Whether or not to provide output on each iteration of
%     the optimization. (Default: false);
% 
%   'seed' - The random seed used to initialize the random number
%     generator for visiting zero weights. (Default: random)
%  
% References:
%
% 1. Krishnapuram, B., Figueiredo, M., Carin, L., & Hartemink, A. (2005)
%   “Sparse Multinomial Logistic Regression: Fast Algorithms and
%   Generalization Bounds.” IEEE Transactions on Pattern Analysis and
%   Machine Intelligence (PAMI), 27, June 2005. pp. 957–968.

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

defaults.lambda = .1;
defaults.prior = 'l1';

defaults.tol = 1e-3;
defaults.max_iter = 1e5;
defaults.decay_rate = 0.25;
defaults.decay_min = 0;

defaults.mex = true;
defaults.verbose = false;
defaults.seed = double(rand()*intmax);

defaults.constant = false;
defaults.w_init = [];
defaults.fit_all = true;

args = propval(varargin, defaults, 'strict', false);

% Error checking + validation
if args.mex & isempty(which('smlr_mex'))
  warning('Unable to find MEX optimized version. Using Matlab routine instead...');
  args.mex = false;
end

if any(all(Y==0,2))
  error('Invalid label entries: %d rows are all zeros.', count(all(Y==0,2)));  
end

if args.prior ~= 'l1' & args.prior ~= 'l2'
  error('Prior ''%s'' is not recognized.', args.prior);
end
if args.prior == 'l2'
  error('Not implemented yet. How did you even know about this?');
end

% Optionally use constant term in regression
if args.constant
  X = [ones(rows(X),1) X];
end  

% Find the right dimensions of data, etc.
[N,M] = size(Y);
[N,d] = size(X);

% Initialize starting point values

if isempty(args.w_init) & args.fit_all
  w = zeros(d,M);
elseif isempty(args.w_init) & ~args.fit_all
  w = zeros(d,M-1);
else
  w = args.w_init;
  if cols(w) == M        % Determine the proper setting of "fit all"
    args.fit_all = true;
  else
    args.fit_all = false;
  end  
end

% Precomputations for speed
B = ((M-1)/(2*M))*(sum(X.^2))';     % [d x 1]

softmax_delta = (args.lambda/2)./B;   % [d x 1] 
smooth_constant = B./(B-args.lambda); % [d x 1]

XY=X'*Y(:,1:(cols(w)));             % [d x (M-1 or M)]

% Compute starting point probabilities
Xw = X*w;
E = exp(Xw);
if ~args.fit_all
  S = sum(E,2)+ones(N,1);
else
  S = sum(E,2);
end

% Resampling probabilities
w_resamp = single(ones(size(w)));

% Run the MEX optimized iteration if specified
if args.mex

  if args.verbose
    disp('SMLR: Using MEX-optimized SMLR routine');
    starttime = clock;
  end 

  [w Xw E S iter] = smlr_mex(w, double(X), double(XY), double(Xw), double(E), double(S), ...
                             double(B), double(softmax_delta), w_resamp, ...
                             args.max_iter, ...
                             args.tol, ...
                             args.decay_rate, ...
                             args.decay_min, ...                             
                             args.seed, ...
                             double(args.verbose));
  wasted = [];
  saved = [];

  if args.verbose
    dispf('Completed (%d iterations, %g seconds)', iter, ...
          etime(clock,starttime));
  end  

  % Compute log posterior  
  log_likelihood = sum( sum(Xw.*Y(:,1:cols(w)),2) - log(S) );
  log_posterior = log_likelihood - args.lambda*sum(abs(w));

  return;
end

% If not, run the Matlab native version: 
if args.verbose
  disp('SMLR: Using Matlab Native SMLR routine');
end

% Initialize looping iterators + performance tracking indicators
w_prev = w;
converged = false;
incr = realmax; 

iter = 1;
basis = 1;

wasted = zeros(args.max_iter,1);
saved = zeros(args.max_iter,1);

if args.verbose
  dispf('SMLR: Using random seed=%d',args.seed);
end

starttime = clock;
% Iteratively update each weight
for iter = 1:args.max_iter
 
  % Go through each weight individually
  for basis = 1:rows(w)
    for m = 1:cols(w)
      
      w_old=w(basis,m);

      % Check already zeroed weights according to a decreasing probability
      if (w_old ~= 0) | (rand() <= w_resamp(basis,m))

        % Compute gradient of log likelihood
        P=E(:,m)./S;  
        grad=(XY(basis,m)-(X(:,basis))'*P);

        w_new = w_old+grad/B(basis);                         

        % Laplacian prior
        w_new = sign(w_new)*max([0, abs(w_new) - softmax_delta(basis)]);          
        
        % Update the running totals if the weight changed
        if w_new ~= w_old
          Xw(:,m)=Xw(:,m)+X(:,basis)*(w_new-w_old);
          
          E_new_m=exp(Xw(:,m));

          S_0 = S;
          S=S+(E_new_m-E(:,m));
         
          E(:,m)=E_new_m;  
          
          w(basis,m)=w_new;          
        end
        
        % Record how often computations were 'wasted' or 'saved'
        if w_new ~= 0 & w_old == 0

          saved(iter) = saved(iter) + 1;
          % Reset resampling probability          
          w_resamp(basis,m) = 1; 
        
        elseif w_new == 0 & w_old == 0

          wasted(iter) = wasted(iter) + 1;
          % Further decay resampling probability
          w_resamp(basis,m) = (w_resamp(basis,m) - args.decay_min)*args.decay_rate + args.decay_min;
          
        end        
        
      end
      
    end
  end
  
  % Assess convergence after each full cycle
  incr = norm(w_prev(:)-w(:))/(norm(w_prev(:))+eps);

  % Display progress if desired
  if args.verbose
    dispf('SMLR [%d]: %g s (saved %d, wasted %d), incr=%g', ...
          iter, etime(clock,starttime), saved(iter), wasted(iter), incr);
  end
  
  if incr < args.tol
    break;
  end  
  
  w_prev=w;
end

% Compute log posterior
log_likelihood = sum( sum(Xw.*Y(:,1:cols(w)),2) - log(S) );
log_posterior = log_likelihood - args.lambda*sum(abs(w));





