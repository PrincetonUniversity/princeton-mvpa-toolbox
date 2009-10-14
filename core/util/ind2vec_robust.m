function [regs] = ind2vec_robust(ind)

% Replacement for ind2vec, can deal with zeros better
%
% [REGS] = IND2VEC_ROBUST(IND)
%
% This script is used to convert vector regressors that list a
% condition for each timepoint into a regressor matrix which
% consists of conditions x timepoints.  It is useful for taking in
% regressors that have been shifted using shift_regressors and that
% therefore begin with a 0 since ind2vec can not input a vector
% that begins with 0.

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

% This command checks to make sure that all of the input values are
% integers and outputs an error if any inputs are not integers.
if isint(ind)==0
  error('Your regressors have to be integers');
end

% This command computes the number of conditions present in the
% regressors by finding the highest value listed in the input
% vector. It also figures out the number of timepoints based on the
% length of the input vector.
nConds = max(ind);
nTimepoints = length(ind);

% This command makes a matrix called regs that has nConds rows and
% nTimepoints columns, which is filled with 0s.
regs = zeros(nConds,nTimepoints);

% This command fills in 1s in a condition's row for every timepoint
% at which that condition is present.
for c=1:nConds
  regs(c,find(ind==c)) = 1;
end
