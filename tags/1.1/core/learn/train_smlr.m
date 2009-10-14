function [scratchpad] = train_smlr(trainpats,traintargs,in_args,cv_args)
% Trains sparse multinomial logistic regression (SMLR) to predict your regressors
%
% [SCRATCHPAD] = TRAIN_SMLR(TRAINPATS,TRAINTARGS,IN_ARGS,CV_ARGS)
%
% Trains a Sparse Multinomial Logistic Regression (SMLR) algorithm
% to predict regressors of interest. For details on the algorithm
% and optional arguemnts, see SMLR.m. 
%
% Arguments:
% 
%   TRAINPATS - A  D x N input matrix of training patterns.
% 
%   TRAINTARGS - A M x N matrix of training labels using one-of-M encoding.

% Outputs:
%
%   SCRATCHPAD - The structure containing all the output of the
%    SMLR algorithm.
%
% SEE ALSO SMLR, TEST_SMLR           

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

sanity_check(trainpats,traintargs,in_args);

% Run SMLR with whatever options the user has passed in
[w class_args] = smlr(trainpats', traintargs', in_args);

% Return the result in the scratchpad struct
scratchpad = bundle(w, class_args);
 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [] = sanity_check(trainpats,traintargs,args)

if isnan(trainpats)
  error('trainpats cannot be NaN');
end
if isnan(traintargs)
  error('traintargs cannot be NaN');
end
