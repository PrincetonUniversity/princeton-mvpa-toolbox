function [feat thresh conf] = decisionStump(wl,trainpats,weight);

% [FEAT THRESH CONF] = DECISIONSTUMP(WL,TRAINPATS,WEIGHT);
%
% Implements weak learner in the form of a decision stump as computed by
% AdaBoost.MH.
%
% This is part of the Princeton MVPA toolbox, released under the
% GPL. See http://www.csbmb.princeton.edu/mvpa for more
% information.
% Author: Melissa K. Carroll
%
% Associated weaklearnerinitializer is decisionStumpInitialize.m.
%
% See weaklearner_template.m for more details on input and output
% arguments.
%
% See Schapire and Singer (1999) for more details on confidence-rated
% AdaBoost using decision stumps.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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

[feat thresh conf] = dstump(double(weight),wl.pos,wl.neg,wl.sortedix,double(wl.epsilon),double(trainpats),double(wl.seed));
