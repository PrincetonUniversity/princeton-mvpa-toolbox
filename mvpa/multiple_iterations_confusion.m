function [confmat guesses desireds] = multiple_iterations_confusion(results)

% [CONFMAT GUESSES DESIREDS] = MULTIPLE_ITERATIONS_CONFUSION(RESULTS)
%
% Loops over the iterations in results, concatenating the
% results.iterations(i).perfmet.desireds and guesses, and then
% feeds in the concatenated versions into confusion to create the
% confusion matrix


guesses = [];
desireds = [];

for i=1:length(results.iterations)
  guesses = [guesses results.iterations(i).perfmet.guesses];
  desireds = [desireds results.iterations(i).perfmet.desireds];
end % r

confmat = confusion(guesses,desireds);

save('confmat.txt','confmat','-ascii')
