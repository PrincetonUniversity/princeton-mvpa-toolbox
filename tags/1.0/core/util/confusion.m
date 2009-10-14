function [confmat] = confusion(guesses,desireds)

% [CONFMAT] = CONFUSION(GUESSES,DESIREDS)
%
% Calculates the confusion matrix for your conditions, i.e. the
% number of times it guessed blah when it should have guessed bloo
%
% This script will output the distribution of guesses for each
% condition. This is useful if you think some of your conditions are
% more similar to others, and so predict that when the classifier
% makes a mistake that it's probably (somewhat forgivably) confusing
% two similar conditions.
%
% GUESSES (1 x nTestTimepoints)
%
% DESIREDS (1 x nTestTimepoints)
%
% CONFMAT = nCondsRightAnswer x nCondsGuesses

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

nConds = max(desireds);
nTestTRs = length(desireds);

if ~isvector(guesses)
  error('Guesses has to be a vector');
end

if length(guesses) ~= nTestTRs
  error('Your guesses are the wrong size');
end

% confmat = nCondsRightAnswer x nCondsGuesses
confmat = zeros(nConds,nConds);

nTestTRsPerCond = nTestTRs / nConds;

for cRA=1:nConds
  % Find all the TRs where there's a non-zero value for this row,
  % i.e. TRs for this condition
  curTRsRightAnswer_idx = find(desireds==cRA);
  
  % For each condition, find how many guesses it made when it
  % should have been guessing condition c
  
  for cG=1:nConds
    % Everything we do inside this loop is going to be concerned with
    % just those TRs where the right answer should have been cRA
    curTRsGuess = guesses(curTRsRightAnswer_idx);
    
    % length(find()) = count (vaguely)
    countTRsGuess = length(find(curTRsGuess==cG));
  
    % Add the count for number of guesses of condition cG when the
    % right answer was actually cRA to position (cG,cRA)
    confmat(cRA,cG) = countTRsGuess;
    
  end
  
end % nConds

confmat = confmat / nTestTRsPerCond;

figure
imagesc(confmat)
colormap(hot)
colorbar



