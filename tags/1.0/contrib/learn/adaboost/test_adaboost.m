function [acts scratchpad] = test_adaboost(testpats,testtargs,scratchpad)

% [ACTS SCRATCHPAD] = TEST_ADABOOST(TESTPATS,TESTTARGS,SCRATCHPAD)
%
% Implements the testing function for AdaBoost.MH/AdaBoost.MO.  See Allwein
% et al. (2001) for details on the implementation of the multi-class to
% binary reduction evaluation.  Logical performance metric is
% perfmet_maxclass_adaboostrounds on computed scores for each of the original classes.
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
% Author: Melissa K. Carroll
%
% NOTE: rest conditions (sum(traintargs,1) == 0) are exluded from testing.
% For that reason, perfmet_maxclass_adaboostrounds should be used instead
% of perfmet_maxclass, since the latter does not exclude rest from
% performance evaluation, which will cause errors.
%
% See test_template.m for more information on the input and output
% arguments.
%
% See train_adaboost.m for the training function corresponding to this
% testing function.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Remove rest conditions from testing
nonrest = find(sum(testtargs,1) > 0);
testtargs = testtargs(:,nonrest);
testpats = testpats(:,nonrest);

numex = size(testpats,2);

% translate from actual classes to mapped classes
class = vec2ind(testtargs);
testtargs = scratchpad.class_args.mapping(:,class);

% determine the dataset dimensions
numclass = size(testtargs,1);
numrounds = size(scratchpad.feature,1);

% initialize the matrix for scoring confidence values for each example for
% each round
confidence = NaN(numclass,numex,numrounds,'single');

% perform for each round (vectorization too inefficient)
for i = 1:numrounds;
    % if AdaBoost was performed multicall, each round will have a different
    % feature/threshold for each mapped class, so do each class separately
    % NOTE: multi-call training is not currently implemented
    % see comments for single-call (else) condition for more detail
    if scratchpad.class_args.multicall;
        for j = 1:numclass;
            block = (testpats(scratchpad.feature(i,j),:) > scratchpad.threshold(i,j)) + 1;
            conf = scratchpad.confidence(j,:,i);
            confidence (j,:,i) = conf(:,block);
        end;
    else;
        % determine the block for each example: 2 if example is above
        % threshold for feature, 1 otherwise
        block = (testpats(scratchpad.feature(i),:) > scratchpad.threshold(i)) + 1;
        % use the block as an index to conf for that round to obtain the
        % confidence scores for each example for each round (for each
        % mapped class)
        conf = scratchpad.confidence(:,:,i);
        confidence(:,:,i) = conf(:,block);
    end;
end;
% sum the confidence matrix to obtain total confidence scores for each
% mapped class for each example
% note that cumsum is performed so predictions for each round can be
% obtained
f = cumsum(confidence,3);
% initialize the arg matrix that will determine the original class with the
% minimum exponential loss over all of its mapped classes
arg = NaN(size(scratchpad.class_args.mapping,2),numex,numrounds,'single');
% compute arg for each original class by multiplying the mappings for each
% of the original class's mapped classes by their confidence scores (for each example), 
% calculating the exponential loss, and summing over all the mapped
% classes
for y = 1:size(scratchpad.class_args.mapping,2);
    map = repmat(scratchpad.class_args.mapping(:,y),[1 numex numrounds]);
    arg(y,:,:) = sum(exp(-1*map.*f),1);
end;

% following the MVPA toolbox format, acts will contain "activations" for
% each original class, in which the maximum score is the prediction for
% that round; since exponential losses are stored in arg, invert them so the maximum
% act will be the prediction for that class
acts = arg(:,:,end);

% place arg in the scratchpad so performance metrics can be computed over
% all AdaBoost rounds
scratchpad.actsarchive = arg;
