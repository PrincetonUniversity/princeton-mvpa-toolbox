# Tutorial on using AdaBoost for classification #

The [AdaBoost](http://en.wikipedia.org/wiki/AdaBoost) classifier code was contributed by [Melissa Carroll](http://www.cs.princeton.edu/~mkc/). It will be included in the 1.0 release, and is also available in the development version here:

[MVPA Adaboost](http://code.google.com/p/princeton-mvpa-toolbox/source/browse/trunk/?r=359#trunk%2Fcontrib%2Flearn%2Fadaboost)

The basic idea behind boosting is to assign a set of weights to the training examples and iteratively re-weight the examples during training so that examples that are still being mis-classified receive higher weights. On each iteration, a new "weak hypothesis," which can be any type of classifier, is chosen to fit the current training example distribution. At the end, all of the weak hypotheses selected are combined into one "strong hypothesis," which serves as the overall classifier. The code in the toolbox uses very simple decision stumps (one node decision trees) as the weak hypotheses.

A good reference for the boosting literature is http://www.cs.princeton.edu/~schapire/boost.html

The code for computing the optimal splitting feature and threshold for the decision stump weak hypothesis on each round is in the dstump.c file.  To run the code, you will need to compile the dstump mex file from the dstump.c file (the code was written in C to be run as a mex file for performance issues).  To do so, simply type mex dstump.c from the shell in the directory in which the code is located (you can also submit this statement from the Matlab command line).  When this is done, you should see a new file in the directory called dstump.**, usually something like dstump.mex** e.g. dstump.mexglx .  This is the binary file Matlab will run when the dstump function is called.

NOTE: if you are compiling the code on a 64-bit system, this compiled code will not function properly.  Another version of the code for 64-bit systems exists - please email mkc@princeton.edu if you need the file (if there is enough demand, this version could likely be included in a future toolbox release).

Once the mex file has been compiled, it can be called like any other function, e.g.:
[thresh conf](feat.md) = dstump(weight,pos,neg,sortedix,epsilon,trainpats,wl.seed);
If you are using the train\_adaboost, test\_adaboost, and perf\_maxclass\_adaboostrounds functions, there shouldn't be a need to run this function directly.

You can also program your own weak classifiers to be plugged into train\_adaboost, though at the moment their functionality is limited.  See the details in the comments for the weaklearner\_template below.  Information on coding mex files can be found here: http://www.mathworks.com/access/helpdesk/help/techdoc/matlab_external/f7667.html .

To use the scripts as is, simply call train\_adaboost, test\_adaboost, and perfmet\_maxclass\_adaboost from within the MVPA code as you would any other training, test, and performance evaluation functions.

Additional documentation helpful for understanding the code can be found in the comments for each of the AdaBoost scripts, which are reproduced below, in alphabetical order by script name:

decisionstump.m
> [THRESH CONF](FEAT.md) = DECISIONSTUMP(WL,TRAINPATS,WEIGHT);

> Implements weak learner in the form of a decision stump as computed by
> AdaBoost.MH.

> Associated weaklearnerinitializer is decisionStumpInitialize.m.

> See weaklearner\_template.m for more details on input and output
> arguments.

> See Schapire and Singer (1999) for more details on confidence-rated
> AdaBoost using decision stumps.


decisionstumpinitialize.m
> [INITIALWEIGHT](DECISIONSTUMPCLASSIFIER.md) = DECISIONSTUMPINITIALIZE(TRAINPATS,TRAINTARGS,EPSILONCONSTANT,SEED);

> Implements decision stump weak learners.  See weaklearnerinitialize\_template.m for template.
> See Schapire and Singer (1999) for more details on decision stumps as
> weak learners in confidence-rated AdaBoost.


dstump.c
> [THRESH CONF](FEAT.md) = DSTUMP(WEIGHT,POS,NEG,SORTEDIX,EPSILON,TRAINPATS,SEED);
> > Computes the feat, thresh, and conf for a weak hypotheses for a dataset on one AdaBoost round


perfmet\_max\_class\_adaboostrounds.m

> [PERFMET](PERFMET.md) = PERFMET\_MAXCLASS\_ADABOOSTROUNDS(ACTS,TARGS,SCRATCHPAD,ARGS)
> Produces the same results as perfmet\_maxclass.m, except that
> minimum exponential loss is evaluated, rather than maximum activation,
> and desireds, corrects, and pcntcorrect are output for every training round
> of AdaBoost, allowing one to evaluate the change in test
> performance over AdaBoost rounds.

> NOTE: rest conditions (sum(traintargs,1) == 0) are exluded from
> evaluation.


test\_adaboost.m
> [SCRATCHPAD](ACTS.md) = TEST\_ADABOOST(TESTPATS,TESTTARGS,SCRATCHPAD)

> Implements the testing function for AdaBoost.MH/AdaBoost.MO.  See Allwein
> et al. (2001) for details on the implementation of the multi-class to
> binary reduction evaluation.  Logical performance metric is
> perfmet\_maxclass\_adaboostrounds on computed scores for each of the original classes.

> NOTE: rest conditions (sum(traintargs,1) == 0) are exluded from testing.
> For that reason, perfmet\_maxclass\_adaboostrounds should be used instead
> of perfmet\_maxclass, since the latter does not exclude rest from
> performance evaluation, which will cause errors.

> See test\_template.m for more information on the input and output
> arguments.

> See train\_adaboost.m for the training function corresponding to this
> testing function.


train\_adaboost.m
> [scratchpad](scratchpad.md) =
> TRAIN\_ADABOOST(TRAINPATS,TRAINTARGS,IN\_ARGS,CV\_ARGS);

> AdaBoost.MH/AdaBoost.MO classifier.  Equivalent to BoosTexter for
> continuous numeric data.

> NOTE: rest conditions (sum(traintargs,1) == 0) are exluded from training.
> Performs confidence-rated, multi-class AdaBoost on trainpats using traintargs as labels.
> Weak learner is flexible, but decision stumps and decision trees are natural choices.
> For more details, please see various papers indexed at http://www.cs.princeton.edu/~schapire/boosting.html,
> including the original AdaBoost paper (Freund and Schapire, 1998), the confidence-rated Boosting paper
> (Schapire and Singer, 1999), and the reducing multi-class to binary paper (Allwein et al. 200-).

> IN\_ARGS optional fields:

> - weaklearnerinitialize (default = 'decisionStumpInitialize'): Weak learner
> initialization function, typically dependent on the weak learner function
> chosen.  Must take arguments trainpats, traintargs, epsilonconstant, and
> randomization seed.  Use weaklearnerinitialize\_template.m to implement a
> user-defined weak learner initilization.

> - weaklearner (default = 'decisionStump'): Weak learner function for
> AdaBoost.  Use weaklearner\_template.m to implement a user-defined weak
> learner.

> - numrounds (default = 10) : number of AdaBoost iterations to perform.

> - epsilon (default = 0.5): Value for epsilon used to initialize weight
> matrix and as smoothing parameter.  See Freund and Schapire 1998 for more details.

> - seed (default = 1): Seed for randomization performed for tie-breaking
> in weak learner (may not be necessary for some weak learners), allowing duplication of results.

> - verbose (default = false): Boolean value indiciating whether
> to print incremental output to the output file id specified by fid.
> Information printed is number of features in training set, number
> of valid (non-unary) features, and a dot each time 100 rounds of AdaBoost
> are performed.

> - fid (default = 1): File handle for producing verbose output (see above).  Only relevant if verbose is set to true.  Default is stdout.

> - mapping (defualt = "one vs. all" - see below): Mapping from original
> labels (y) to labels used for multi-class AdaBoost (y') in form [y' X y].
> See Allwein et al. (2001) for more details on reducing multi-class to binary.  Examples for 3 class labels include:
    * one vs all (DEFAULT):
> > > [1 -1 -1;
> > > -1 1 -1;
> > > -1 -1 1]
    * all-pairs:
> > > [1 -1 0;
      1. 0 -1;
> > > 0 1 -1]
    * ECOC (user-defined):
> > > [1 -1 -1;
      1. -1 1;
> > > 0 1 -1]


> - multicall (default = false): Boolean value indiciating whether
> single-call (false) or multi-call (true) multi-class classification
> should be performed.  See Allwein et al. (2001) for more information on
> the difference between the two.


weaklearner\_template.m
> function [thresh conf](feat.md) = weaklearner\_template(wl,trainpats,weight);
> Template for defining weak learner functions for AdaBoost.  Implements
> learning function and chooses a returned weak hypothesis.  See
> decisionStump.m for an example.
> For now, the chosen weak hypothesis must be of the form of a binary
> feature/threshold combination and associated confidence scores for the
> target classes.

> Required input arguments passed from train\_adaboost.m:

> - wl: weak learner parameters initialized by weak learner initialization
> (see weaklearnerinitialize\_template.m)

> - trainpats: training patterns passed to classifier from
> cross\_validation.m

> - weight: weights of the weak hypotheses generated by AdaBoost so far.

> Required output (defining the weak hypothesis)

> - feat: feature number (i.e. row in trainpats)

> - thresh: threshold value for feature

> - conf: nOUT x 2 matrix defining confidence scores for each of the target
> classes when feat is below thresh value (col 1) or above thresh value
> (col 2).


weaklearnerinitialize\_template.m
function [initialweight](wl.md) = weaklearnerinitialize\_template(trainpats,traintargs,epsilonconstant,seed);

> Template for defining weak learner initialization functions for AdaBoost.  See
> decisionStumpInitialize.m for an example.