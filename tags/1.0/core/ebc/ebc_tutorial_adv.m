% Tutorial script for predicting the EBC data - "Advanced" Version
%
% This tutorial will guide you in a step-by-step fashion through all
% of the analysis necessary to recreate one of the Princeton EBC
% Team's submissions to the competition.  Unlike the first tutorial,
% we will analyze all thirteen primary regressors for all three
% subjects.  Comments will be sparser, as it is assumed that you know
% the basic structures MVPA uses. If you are completely new to the
% toolbox, please try the 'introduction' tutorial first
% (ebc_tutorial_intro.m).
%
% Unlike the 'introduction' tutorial, this file is highly
% modularized.  If we were to stick all the loading, preprocessing,
% optimization, and testing code into a single file, it would
% quickly become unmanagable. Thus the steps of the analysis are
% broken down into separate .m files.  This also allows us to
% specify parameters to turn certain preprocessing steps on or
% off.  One down-side is that there is a lot more general MATLAB
% programming code required to handle processing these parameters,
% but the extra functionality is well worth it.
%
% To use this tutorial, you can simply run it and see what
% happens. Or, you can step through this file line by line, reading
% the comments; when you come to a particular module, please open that
% file before proceeding.  If you can understand most of what goes
% on in this decently complicated learning experiment, you will
% know everything you need to know to use this toolbox.
%
% Note: this tutorial assumes you have downloaded all files required to
% install the MVPA toolbox and EBC extensions, as well as the
% tutorial EBC data for all three subjects.  For installation
% instructions, please see the online documentation:
%
% http://www.csbmb.princeton.edu/mvpa/ebc/install.html
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

clear subj;

% Load the tutorial parameters structure
load 'ebc_params';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Step 1 - Setup loop for all three subjects' data.
%
% All analysis will be performed for all three subjects, so to
% conserve RAM we perform a loop over each dataset
for subject = 1:3

  % load the optimized parameters for spatial averaging with blanks
  % left in the training set
  default_params = ebc_params{subject, 3, 1};

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Step 2 - Setup the subj structure.

  % ebc_tutorial_adv_load takes in a subject number and the path to
  % the data files, and returns a fully initialized 'subj' structure.
  subj = ebc_tutorial_adv_load(subject, 'data/');

  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Step 3 - Pre-processing.  

  % See ebc_tutorial_adv_preprocess.m for details: this performs
  % the preprocessing steps of analysis.  If we set 'noblanks' to
  % false, then blanks will not be excluded from the analysis.
  subj = ebc_tutorial_adv_preprocess(subj, default_params, ...
                                     'noblanks', false);

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Step 4 - Optimization
  
  % See ebc_tutorial_adv_optimize.m for details: this performs the
  % optimization (temporal and spatial averaging) step of the
  % analysis. Depending on what optimizations were performed, the name
  % of the pattern object to be used in classification will change, so
  % we receive 'patstem' as a secondary output argument to
  % automatically save this for us.
  [subj patstem] = ebc_tutorial_adv_optimize(subj, default_params, 'sfilter', true);
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Step 5 - Regression/Prediction - n-minus-one cross validation

  % See ebc_tutorial_adv_xval.m for details: this performs the
  % multiple cross validation experiments necessary to test each
  % regressor, and records the results in an arrray.  
  [subj results] = ebc_tutorial_adv_xval(subj, patstem, default_params);
  
  % Prints out an informative summary of our results:
  p = zeros(2,numel(results));
  for r = 1:numel(results)
    for i = 1:2
      p(i,r) = results(r).iterations(i).perf;
    end
  end
  
  fprintf('Generalization Performance Summary, Subject %d:\n', subject);
  fprintf('\tmovie #2 to movie #1:%.3f\n', ...
          mean(p(1,:)));
  fprintf('\tmovie #1 to movie #2:%.3f\n', ...
          mean(p(2,:)));
  fprintf('\ttotal: %.3f\n', mean([results.total_perf]));


  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Step 6 - EBC output
  %
  % To get an official estimate of our score using the EBC provided
  % Feature_Rater program, (you must download this separately from
  % their website, see the installation instructions) we output our
  % predictions in the specific format. 
  ebc_feature_rater(subj, results, 2, subject, sprintf('ebc_tutorial_adv_subj_%d.txt', subject));
  

  save(sprintf('results%g', subject), 'results');

  % end our loop over subjects
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Step 7 - Across Subject Averaging
%
% As a final optimization step, we average together the predictions
% from all three subjects to form our final prediction.
avgresults = ebc_average_results(subj, 'results');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Conclusion
%
% This concludes the advanced tutorial.  After completion, you
% should now have submission files ebc_tutorial_adv_subj_1.txt,
% ebc_tutorial_adv_subj_2.txt, and ebc_tutorial_adv_subj_3.txt, as
% well as avg1.txt, avg2.txt, and avg3.txt.  If
% you run the Feature_Rater like this:
%
% Feature_Rater -est1 avg1.txt
%               -est2 avg2.txt
%               -est3 avg3.txt
%
%
% You should get a final score of 0.476.  Not too shabby!
