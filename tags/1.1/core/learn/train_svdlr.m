function [scratchpad] = train_svdlr(trainpats,traintargs,in_args,cv_args)

% Experimental classifier: SVD combined with logistic regression.
%
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

X = trainpats';
Y = traintargs';

N = rows(X); P = cols(X);

defaults.nfolds = max([cv_args.n_iterations, 3]);

defaults.verbose = 0;
defaults.seed = urandom();
defaults.keep = min([N 300]); %
defaults.perfmet = 'perfmet_maxclass';

% Two preset configurations for using SMLR or L2 logistic regression
l1args.nrepeats = 1;

l1args.grid_field = 'lambda';
l1args.grid_vals = [0.001 0.01 0.05 .1 0.5 1 5 10 50 100];

l1args.class_args = struct('constant', true);
l1args.trainfunc = 'train_smlr';
l1args.testfunc = 'test_smlr';

% General options
l2args.nrepeats = 1;

l2args.grid_field = 'penalty';
l2args.grid_vals = [1e-8 1e-7 1e-6 1e-5 1e-4 1e-3 0.01 0.1 1 10 100 ...
                   500 1000 5000];

l2args.class_args = struct('constant', true, 'tol', 1e-8, ...
                           'scale_penalty', true);
l2args.trainfunc = 'train_logreg';
l2args.testfunc = 'test_logreg';

if isfield(in_args, 'mode')
  if strcmp(in_args.mode, 'l1')
    defaults = mergestructs(l1args, defaults);
  elseif strcmp(in_args.mode, 'l2')
    defaults = mergestructs(l2args, defaults);    
  else
    error('Unrecognized preconfiguration mode ''%s''', ...
          in_args.mode);
  end
else
  defaults = mergestructs(l2args, defaults);
end

args = mergestructs(in_args,defaults);

trainfunc = arg2funct(args.trainfunc);
testfunc = arg2funct(args.testfunc);
errfunc = arg2funct(args.perfmet);

% Divide the data into folds:
randn('state', args.seed);
rand('twister', args.seed);

if args.verbose
  dispf('');
  dispf(['SVDLR:Computing SVD on %d x %d matrix --> keeping %d ' ...
         'principal components'], rows(X), cols(X), args.keep);
end

[U,S,V] = fastsvd(X, 'keepNumberComponents', args.keep);
Z = U*S;
W = V;

if args.verbose
  dispf('SVDLR:Completed.');
end

warning('off', 'MATLAB:nearlySingularMatrix');


if args.verbose
  dispf('SVDLR:Using logistic regression method ''%s''', args.trainfunc);  
  dispf(['Running %d-fold crossvalidation %d times to determine ' ...
         'optimal pararameter ''%s'''], args.nfolds, args.nrepeats, ...
        args.grid_field);
end

for r = 1:args.nrepeats

  % Find the best classification parameter
  max_err = -Inf; best_lambda = Inf;
  test_err = []; 
  
  blocks = random_blocks(Y, args.nfolds);  
  t0 = clock;
  for i = 1:numel(args.grid_vals)
  
    val = args.grid_vals(i);
    
    [test_err(i) xval_info(i)] = lr_crossval(val);
    train_err(i) = mean(xval_info(i).train_err);
    
    [t0 timeleft] = eta(i, numel(args.grid_vals), t0);  
    
    if args.verbose > 1
      dispf('SVDLR:%s: %g --> train: %g, test: %g (ETA: %s)', args.grid_field, ...
            args.grid_vals(i), train_err(i), test_err(i), estimate(timeleft)); 
    end
    
    if test_err(i) > max_err
      best_lambda = val;
      max_err = test_err(i);
    end
    
  end

  if args.verbose > 1
    dispf('SVDLR:Selected lambda=%g', best_lambda);
  end
  
  best_lambdas(r) = best_lambda;
  repeat_blocks{r} = blocks;
end

best_lambda = mean(best_lambdas);

if args.verbose
  dispf('SVDLR:Using lambda=%g', best_lambda);
end

% Now run for "real":
if args.verbose
  warning('on', 'MATLAB:nearlySingularMatrix');
end

  
  in_args = mergestructs(args.class_args, struct(args.grid_field, ...
                                                 best_lambda));
  
  classifier = trainfunc(Z', Y', in_args, []);


  scratchpad = mergestructs(bundle(classifier, testfunc, Z,W, blocks, xval_info, ...
                                 best_lambda, max_err, best_lambdas), args);

warning('on', 'MATLAB:nearlySingularMatrix');
% ------------------------------------------------------------------------
% lr_crossval: cross validate to get an estimate of test error
% ------------------------------------------------------------------------

function [err info] = lr_crossval(lambda)

for n = 1:args.nfolds

  test_idx = (blocks == n);
  train_idx = ~test_idx;

  in_args = mergestructs(args.class_args, struct(args.grid_field, ...
                                                 lambda));
  
  classifier(n) = trainfunc(Z(train_idx,:)', Y(train_idx,:)', ...
                            in_args, []);

  [Yhat_train] = testfunc(Z(train_idx,:)', Y(train_idx,:)', ...
                                  classifier(n));  
  [Yhat_test] = testfunc(Z(test_idx,:)', Y(test_idx,:)', ...
                                  classifier(n));
  
  pm = errfunc(Yhat_train, Y(train_idx,:)', classifier(n));
  train_err(n) = pm.perf;
  
  pm = errfunc(Yhat_test, Y(test_idx,:)', classifier(n));
  test_err(n) = pm.perf;
end

info = bundle(train_err, test_err);
err = mean(test_err);

% ------------------------------------------------------------------------
% End fully nested function
end


% ------------------------------------------------------------------------
% End fully nested function
end
  
