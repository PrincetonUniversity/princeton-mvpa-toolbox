function [scratchpad] = train_adaboost(trainpats,traintargs,in_args,cv_args)

% [scratchpad] =
% TRAIN_ADABOOST(TRAINPATS,TRAINTARGS,IN_ARGS,CV_ARGS);
%
% AdaBoost.MH/AdaBoost.MO classifier.  Equivalent to BoosTexter for
% continuous numeric data.
%
% NOTE: rest conditions (sum(traintargs,1) == 0) are exluded from training.
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
% Performs confidence-rated, multi-class AdaBoost on trainpats using traintargs as labels.  
% Weak learner is flexible, but decision stumps and decision trees are natural choices.  
% For more details, please see various papers indexed at http://www.cs.princeton.edu/~schapire/boosting.html, 
% including the original AdaBoost paper (Freund and Schapire, 1998), the confidence-rated Boosting paper 
% (Schapire and Singer, 1999), and the reducing multi-class to binary paper (Allwein et al. 200-).
% 
% IN_ARGS optional fields:
% 
% - weaklearnerinitialize (default = 'decisionStumpInitialize'): Weak learner
% initialization function, typically dependent on the weak learner function
% chosen.  Must take arguments trainpats, traintargs, epsilonconstant, and
% randomization seed.  Use weaklearnerinitialize_template.m to implement a
% user-defined weak learner initilization.
% 
% - weaklearner (default = 'decisionStump'): Weak learner function for
% AdaBoost.  Use weaklearner_template.m to implement a user-defined weak
% learner.
% 
% - numrounds (default = 10) : number of AdaBoost iterations to perform.
% 
% - epsilon (default = 0.5): Value for epsilon used to initialize weight
% matrix and as smoothing parameter.  See Freund and Schapire 1998 for more details.
% 
% - seed (default = 1): Seed for randomization performed for tie-breaking
% in weak learner (may not be necessary for some weak learners), allowing duplication of results. 
%     
% - verbose (default = false): Boolean value indiciating whether
% to print incremental output to the output file id specified by fid.
% Information printed is number of features in training set, number
% of valid (non-unary) features, and a dot each time 100 rounds of AdaBoost
% are performed.
%
% - fid (default = 1): File handle for producing verbose output (see above).  Only relevant if verbose is set to true.  Default is stdout.
% 
% - mapping (defualt = "one vs. all" - see below): Mapping from original
% labels (y) to labels used for multi-class AdaBoost (y') in form [y' X y].
% See Allwein et al. (2001) for more details on reducing multi-class to binary.  Examples for 3 class labels include:
%     * one vs all (DEFAULT): 
%         1 -1 -1
%         -1 1 -1
%         -1 -1 1
%     * all-pairs:
%         1 -1 0
%         1 0 -1
%         0 1 -1
%     * ECOC (user-defined):
%         1 -1 -1
%         1 -1 1
%         0 1 -1
%
% - multicall (default = false): Boolean value indiciating whether
% single-call (false) or multi-call (true) multi-class classification
% should be performed.  See Allwein et al. (2001) for more information on
% the difference between the two.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% set up the default arguments
defaults.weaklearnerinitialize = 'decisionStumpInitialize';
defaults.weaklearner = 'decisionStump';
defaults.numrounds = 10;
defaults.epsilonconstant = 0.5;
defaults.seed = 1;
defaults.verbose = false;
defaults.fid = 1;
defaults.mapping = ones(size(traintargs,1),'single')*-1;
for i = 1:size(traintargs,1);
    defaults.mapping(i,i) = 1;
end;
defaults.multicall = false;

args = add_struct_fields(in_args,defaults);
scratchpad.class_args = args;

% exclude rest if necessary
nonrest = find(sum(traintargs,1) > 0);
traintargs = traintargs(:,nonrest);
trainpats = trainpats(:,nonrest);

% recode the regressors into "label" form
class = vec2ind((traintargs == 1));
traintargs = args.mapping(:,class);

% optionally print out the number of original features
if args.verbose; fprintf(args.fid,'Total features: %i\n',size(trainpats,1)); end;

% determine the valid (i.e. non-unary) features since unary features are
% not informative
valid = find(min(trainpats,[],2) ~= max(trainpats,[],2));

% select only the valid features and *transpose trainpats* to facilitate
% future calculations
trainpats = trainpats(valid,:)';

% optionally print out the number of valid features
if args.verbose; fprintf(args.fid,'Valid features: %i\n',size(trainpats,2)); end;

% intitialize the weak learner
weaklearnerinitialize = str2func(args.weaklearnerinitialize);
[wl weight] = weaklearnerinitialize(trainpats,traintargs,args.epsilonconstant,args.seed); %not wasteful b/c Matlab does copy-on-write so essentially pass-by-ref

% create the scratchpad fields that will store the weak hypotheses
% information
scratchpad.feature = NaN(args.numrounds,1,'single');
scratchpad.threshold = NaN(args.numrounds,1,'single');
scratchpad.confidence = NaN(wl.numclasses,2,args.numrounds);

% generate the weak hypotheses
for t = 1:args.numrounds;
    
    % optionally print out a 100-round marker
    if args.verbose && (mod(t,100) == 0);
        fprintf(args.fid,'.');
    end;
    
    % generate the weak hypothesis for this round
    weaklearner = str2func(args.weaklearner);
    [feat thresh conf] = weaklearner(wl,trainpats,weight);
    scratchpad.feature(t) = valid(feat);    
    scratchpad.threshold(t) = thresh;
    scratchpad.confidence(:,:,t) = conf;
    
    % evaluate the weak hypothesis on the training set
    block = (trainpats(:,feat) > thresh) + 1;
    confidence = conf(:,block);
    clear feat thresh conf;
    
    % update the example weights
    prenormalizedweight = weight.*exp(-1*confidence.*traintargs);
    normconstant = sum(sum(prenormalizedweight));
    weight = prenormalizedweight./normconstant;
end;  

if args.verbose; fprintf(args.fid,'\n'); end;
