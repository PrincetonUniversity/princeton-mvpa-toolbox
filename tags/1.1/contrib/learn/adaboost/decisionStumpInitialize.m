function [decisionStumpClassifier initialweight] = decisionStumpInitialize(trainpats,traintargs,epsilonconstant,seed);

% [DECISIONSTUMPCLASSIFIER INITIALWEIGHT] = DECISIONSTUMPINITIALIZE(TRAINPATS,TRAINTARGS,EPSILONCONSTANT,SEED);
%
% Implements decision stump weak learners.  See weaklearnerinitialize_template.m for template.
% See Schapire and Singer (1999) for more details on decision stumps as
% weak learners in confidence-rated AdaBoost.
%
% This is part of the Princeton MVPA toolbox, released under the
% GPL. See http://www.csbmb.princeton.edu/mvpa for more
% information.
% Author: Melissa K. Carroll
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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

% Initialize the returned classifier struct and calculate dataset
% information
decisionStumpClassifier = [];
numexamples = size(trainpats,1);
numclasses = size(traintargs,1);
numfeatures = size(trainpats,2);

% calculate the epsilon value and initial weights of the training examples
epsilon = epsilonconstant/(numexamples.*numclasses);
initialweight = repmat(epsilon,numclasses,numexamples).*abs(traintargs);
initialweight = initialweight./sum(sum(initialweight)); %(normalize)

% Pre-sort the values in each feature to allow rapid searching of optimal
% splitting thresholds.  Retain the indices in the original matrix to
% maintain link to labels.
[val idx] = sort(trainpats,1,'ascend');

% Save the indices to be used as pointers by the decision stump code.
% Since the values will be pointers, their size is architecture-dependent.
% Determine the appopriate size based on the architecture.
[filename, mode, machineformat, encoding] = fopen(1);
arch = machineformat(end - 1:end);
if strcmp(arch,'64') == 1;
    decisionStumpClassifier.sortedix = int64(idx);
else;
    decisionStumpClassifier.sortedix = int32(idx);    
end;
clear val;

% create the logical matrices encoding whether training examples are
% positive (1) or negative (0) examples for each class.
decisionStumpClassifier.pos = (traintargs == 1);
decisionStumpClassifier.neg = (traintargs == -1);

% Save the dataset information in the returned classifier struct
decisionStumpClassifier.numexamples = numexamples;
decisionStumpClassifier.numfeatures = numfeatures;
decisionStumpClassifier.numclasses = numclasses;
decisionStumpClassifier.epsilon = epsilon;
decisionStumpClassifier.seed = seed;