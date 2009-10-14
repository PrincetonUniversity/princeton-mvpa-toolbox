function [errs warns] = unit_confusion()

% [ERRS WARNS] = UNIT_CONFUSION()
% 
% Tests the CONFUSION confusability matrix calculation.


errs = {};
warns = {};


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BASIC TEST

[g d] = create_synth_guesses_desireds();

actual = confusion(g,d);
% N.B. this DESIRED variable is for testing purposes, and has nothing
% to do with the GUESSES/DESIREDS (labelled here G and D) that
% CONFUSION uses.
%
% nCondsRightAnswer x nCondsGuesses. these are proportions
desired = [.75  .25  0; ...
           0    1    0; ...
           .4   .2  .4 ];

if ~isequal(actual,desired)
  errs{end+1} = 'Basic test';
  keyboard
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [g d] = create_synth_guesses_desireds()

% i decided against auto-generating. better to set them up
% deterministically once by hand, and then it's clearer to the eye
% what the right answers to the tests should be
%
% DESIREDS, i.e. classifier right answer targets
d = [1 1 1 1 ...
     2 2 2 2 ...
     3 3 3 3 3];
% GUESSES, i.e. the index of the most active classifier output unit
% (for PERFMET_MAXCLASS)
g  = [1 1 1 2 ... % 1 wrong
      2 2 2 2 ... % 0 wrong
      3 3 2 1 1]; % 3 wrong

% nConds = 3;
% nTimepointsPerCond = 4;
% desireds = [];
% for c=1:nConds
%   desireds = [desireds ones(1,nTimepointsPerCond)*c];
% end % c nConds



