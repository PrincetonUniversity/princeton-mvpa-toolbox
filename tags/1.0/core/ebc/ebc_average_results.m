function [avgresults] = ebc_average_results(subj, stem)

% Averages results structure across subjects
%
% [AVGRESULTS] = EBC_AVERAGE_RESULTS(SUBJ, STEM)
%
% Loads three .mat files with the name STEM<N>.MAT, where N
% ranges from 1 to 3.  Averages the "acts" field of the
% results.iterations struct across all three data files for
% each regressor and each iteration.  Then these are output
% for use in the EBC Feature_Rater scoring program, with the
% same mean values for each subject.
%
% SUBJ should be one of the subjects who was used in the
% analysis.
%
% STEM should be the beginning of the filenames where the
% results from each subject were saved.  (e.g., if you saved
% them as 'results1.mat', 'results2.mat', and
% 'results3.mat', you should enter 'results' as the STEM.)
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

for s = 1:3
  load(sprintf('%s%g', stem, s));
  results_array{s} = results;
end

results = results_array;

% get predictions for each subject for each iteration, etc...
for r = 1:numel(results{1})       

    % start with a copy of the first subject's results
    avgresults(r) = results{1}(r);    

    for i = 1:numel(avgresults(r).iterations)

      actsavg = zeros(size(avgresults(r).iterations(i).acts));
      
      for s = 1:numel(results)
        actsavg = actsavg + results{s}(r).iterations(i).acts;
      end

      avgresults(r).iterations(i).acts = actsavg ./ sum(actsavg);

    end
    
end

% output the averaged files
for subject = 1:3
  
  ebc_feature_rater(subj, avgresults, 2, ...
                    subject, sprintf('avg%d.txt', subject));
  
end

