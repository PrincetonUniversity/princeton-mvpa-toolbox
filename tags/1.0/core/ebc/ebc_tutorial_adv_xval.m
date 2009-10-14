function [subj results] = ebc_tutorial_adv_xval(subj, patstem, default_params) 

% Perform cross-validation experiment for advanced EBC tutorial
% 
% [SUBJ RESULTS] = EBC_TUTORIAL_ADV_XVAL(SUBJ)
%
% Performs one cross validation experiment for each regressor in
% the group 'baseregs_grp'.  The PATSTEM argument will have the
% regressor name attached to it to form the pattern name for
% experiment.  i.e. 'epi_z_tavg' becomes 'epi_z_tavg_Amusement' for
% the 'Amusement' regressor.
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Step 5 - Regression/Prediction - n-minus-one cross validation
%
% We once again loop through each regressor, this time performing
% a leave-out-one cross-validation regressor experiment.  Our
% performance metric is 'perfmet_xcorr', the standard cross
% correlation coefficient between the regressor and the feature.

fprintf('Performing cross-valdiation on subject ''%s''...\n', ...
        subj.header.id);

% the entire experiment is repeated for each regressor
rnames = find_group(subj, 'regressors', 'baseregs_grp');
for r = 1:numel(rnames)

  % we will use ridge regression as our classifier
  class_args.train_funct_name = 'train_ridge';
  class_args.test_funct_name = 'test_ridge';

  % use a predetermined roughly well-performing parameter
  class_args.penalty = default_params.penalty(r) * default_params.N(r);

  % Get the name of the regressor and mask (they're the same)
  regsname = rnames{r};				  
  maskname = regsname;

  % Build the name of the pattern to be used (see above)
  patname = sprintf('%s_%s', patstem,regsname);
  
  fprintf('Prediction for: %s\n', regsname);
  
  % Perform the (n-1) cross validation experiment with our custom
  % parameters:  
  [subj result] = cross_validation(subj, patname, regsname, ...
                                   'movies_xval', ...
                                   maskname, ...
                                   class_args, ...
                                   'perfmet_functs', ...
                                   'perfmet_xcorr', ...
                                   'perfmet_args', {[]});

  % save the results of this experiment into an array that will
  % contain the info from all thirteen regressors
  results(r) = result;
  
end

fprintf('cross valdiation completed. Average total_perf - %g\n', ...
        mean([results.total_perf]));

