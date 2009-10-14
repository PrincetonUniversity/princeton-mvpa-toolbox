function [confmat] = confusion(guesses,desireds,varargin)

% [CONFMAT] = CONFUSION(GUESSES,DESIREDS, ...)
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
% The diagonals give the classification performance values for each of
% your conditions.
%
% The easiest way to call this script for a given RESULTS structure is
% to use MULTIPLE_ITERATIONS_CONFUSION.M.
%
% GUESSES (1 x nTestTimepoints)
%
% DESIREDS (1 x nTestTimepoints)
%
% CONFMAT = nCondsRightAnswer x nCondsGuesses
%
% SCALE_AXIS_ONE (optional, default = false). If true, sets the
% colorbar axis to 1, so that the colors are fixed across subjects.
%
% DO_PLOT (optional, default = false).

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


defaults.scale_axis_one = false;
defaults.do_plot = false;
args = propval(varargin,defaults);

nConds = max(desireds);
nTestTRs = length(desireds);

assert(isvector(guesses));
assert(isvector(desireds));
if length(guesses) ~= nTestTRs
  error('Your guesses are the wrong size');
end

% confmat = nCondsRightAnswer x nCondsGuesses
confmat = zeros(nConds,nConds);

for cRA=1:nConds
  % how many timepoints in this condition?
  countTRsRightAnswer = count(desireds==cRA);
  for cG=1:nConds
    % how many times did the classifier guess condition cG when the
    % right answer is cRA?
    countTRsGuess = count(desireds==cRA & guesses==cG);
    % normalize this by the number of times the right answer is cRA
    normTRsGuess = countTRsGuess / countTRsRightAnswer;
    % proportion of guesses of condition cG when the right answer was
    % actually cRA
    confmat(cRA,cG) = normTRsGuess;
  end
end % nConds

if args.do_plot
  figure
  imagesc(confmat)
  colormap(hot)
  if args.scale_axis_one
    set(gca,'CLim',[0 1])
  end
  colorbar
  xlabel('Guessed')
  ylabel('Right answer')
end % if do_plot

