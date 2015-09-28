# Classification #

## Introduction ' training, testing and generalization ##

In the machine learning sense, classification means taking a labelled training data set and showing the classifier algorithm examples of each condition over and over until it can successfully identify the training data. Then, the classifier's generalization performance is tested by asking it to guess the conditions of new, unseen data points.

In terms of fMRI experiments, this amounts to a very simple kind of mind-reading ' being able to tell something about what the subject was thinking about at a given moment by looking at the activity in their brain, based on how their brain looked in the past when thinking about similar kinds of things. In practice, it only tends to work for making very crude guesses about the kind of task being performed, or stimuli being viewed.

The way we tend to test this is to train on most of the data, and then test our classifier's generalization performance on the remainder. By training, we mean showing it lots of examples of that person's brain when in condition A, and telling it each time, 'This is an example of the brain in condition A'. We then show it lots of examples of the same brain in condition B, also telling it which condition these brain examples came from.

For instance, we might train the classifier on examples from runs 1-9 of a 10-run experiment, and then see whether it guesses correctly when faced with data from run 10.


## Performance ##

The performance metric measures the similarity between the output produced by a classifier to the output it's supposed to produce.

The simplest performance metric for classification is to ask whether the maximally-active category unit from the classifier corresponds to the maximally (or only) active condition in the regressors/targets. If so, that timepoint is 'correct', otherwise it's 'wrong'. This is all that the [''perfmet\_maxclass.m''](http://code.google.com/p/princeton-mvpa-toolbox/source/browse/trunk/core/learn/perfmet_maxclass.m) performance metric function does.

Another performance metric that's often used in Neural Networks is the mean squared error.

There are many alternative and more sophisticated ways of evaluating performance.

See '[Creating your own performance metric function](#_Creating_your_own_3.md)' if you don't want to use ''perfmet\_maxclass.m''.


## Creating your own performance metric function ##

If you want to create your own performanc metric, start by looking at the default [perfmet\_maxclass.m](http://code.google.com/p/princeton-mvpa-toolbox/source/browse/trunk/core/learn/perfmet_maxclass.m), and the [perfmet\_template.m](http://code.google.com/p/princeton-mvpa-toolbox/source/browse/trunk/core/template/perfmet_template.m) template.

Here are the requirementss:

  * Should take in a (nOutputUnits x nTimepoints) ''acts'' matrix of responses from the testing function
  * Should take in a (nOutputUnits x nTimepoints) ''targs'' matrix of desired responses (supervised labels)
  * ''Args'' can contain any further information your custom perfmet function requires
  * Should return a ''perfmet'' structure that has a ''perf'' scalar field containing the overall performance according to your performance metric. Any other information that might be useful later can be stored in the ''perfmet'' structure.


## N-minus-one (leave-one-out) cross-validation ##

The method of training on most of the data and generalization-testing on the remainder is somewhat wasteful and potentially misleading. It could be that generalization performance for a particular run is very good or very bad. So you might want to try withholding a different run for testing, and training on the remainder, using a fresh classifier, to see whether the same kind of performance is obtained.

N-minus-one (leave-one-out) cross-validation is really just that idea taken to its extreme. If we have 10 runs, then we will run 10 separate classifiers, each one being generalization-tested on a different 1/10 of the data having been trained on the remaining 9/10. This way, every timepoint gets a turn at being part of the test set, and 9 turns at being part of the training set.

The toolbox is set up to make this kind of procedure very easy


## Backpropagation ##

Backpropagation is an algorithm for training a neural network, that is, for adjusting the weights connecting units so that a desired output is produced for a given input. It's a powerful algorithm, and we have found that the conjugate gradient variant that is set to be the default classifier for the toolbox learns quickly and generalizes well.

In order to use the default classifier in the toolbox, you will need a copy of the Matlab [Neural Networks toolbox](http://www.mathworks.com/products/neuralnet/). If you don't have one, you can use [''train\_bp\_netlab.m''](http://code.google.com/p/princeton-mvpa-toolbox/source/browse/trunk/core/learn/train_bp_netlab.m) (not yet ready) instead, which uses the open source [Netlab toolbox](http://www.ncrg.aston.ac.uk/netlab/) backpropagation function instead.

See the Matlab Neural Networks toolbox [documentation](http://www.mathworks.com/access/helpdesk/help/toolbox/nnet/) for more information, such as how to examine the classifier weights or the activations of the hidden layer.

Note: the default algorithm for [train\_bp.m](http://code.google.com/p/princeton-mvpa-toolbox/source/browse/trunk/core/learn/train_bp.m) is conjugate gradient ('traincgb'), mainly for historical reasons. However, the default for the Netlab net is scaled conjugate gradient (which is similar to 'trainscg'). It's all much of a muchness, though we're starting to think that 'trainscg' may be the way forward ' see the [Howto's](#_My_classifier_sometimes.md) Classification section.


## Included classifiers ##

Currently, [backpropagation](#_Backpropagation.md) is the only classifier algorithm included with the toolbox. We intend to rapidly expand the list of included classifiers in future releases, but in the meantime, it's extremely easy to [add new classifiers yourself](#_Creating_your_own_1.md).


## Creating your own training function ##

If you want to create your own classifier training function, start by looking at the default [train\_bp.m](http://code.google.com/p/princeton-mvpa-toolbox/source/browse/trunk/core/learn/train_bp.m), and the [train\_template.m](http://code.google.com/p/princeton-mvpa-toolbox/source/browse/trunk/core/template/train_template.m) template.

This training function will also need a corresponding [testing function](#_Creating_your_own_2.md) that actually tests generalization to unseen data. It is worth noting that some classifiers don't need a training phase, in which case the training function should simply return an empty scratchpad.

Here are the requirements, based on ''train\_bp.m'':

  * should take in ''trainpats'' (''nFeatures'' x ''nTrainingTimepoints'') training patterns
  * should take in ''traintargs'' (''nOutputUnits'' x ''nTrainingTimepoints'')
  * should take in a ''train\_args'' structure containing fields specific to the classifier
  * should return a ''scratchpad'' structure that the corresponding [testing function](#_Creating_your_own_2.md) knows how to use to test the classifier

Since we couldn't think of a sufficiently broad term to encompass all possible classifier algorithms, we have adopted the term 'output units' to refer generically to the number of rows in the teacher signal (i.e. supervised labels) being fed to the classifier.


## Creating your own testing function ##

If you want to create your own classifier testing function, start by looking at the default [test\_bp.m](http://code.google.com/p/princeton-mvpa-toolbox/source/browse/trunk/core/learn/test_bp.m), and the [test\_template.m](http://code.google.com/p/princeton-mvpa-toolbox/source/browse/trunk/core/template/test_template.m) template.

Most classifiers need to be trained by a [training function](#_Creating_your_own_5.md) before being tested. The training function will create the scratchpad that contains whatever information is required at testing.

Here are the requirements, based on ''test\_bp.m'':

  * should take in ''testpats'' (''nFeatures'' x ''nTestingTimepoints'')
  * should take in ''testtargs'' (''nOutputUnits'' x ''nTestingTimepoints'')
  * should take in a ''scratchpad'' which contains whatever fields are needed by the testing algorithm (e.g. a trained net) created by the corresponding [training function](#_Creating_your_own_5.md)
  * should return an ''acts'' matrix (''nOutputUnits ''x ''nTestingTimepoints''), the same size as the ''testtargs'', which contains the classifier's guesses in response to the ''testpats''. These ''acts'' get compared to the ''testtargs''.
  * should return the ''scratchpad'', in case the test function added to it


## The results structure ##

The ''results'' structure stores everything you might need after a classification analysis.

It's divided up by iteration, one for each iteration of the n-minus-one (or whatever cross-validation method described by the selector group passed to ''cross\_validation.m''). The following fields are contained in an ''iteration'' (not in this order):

  * ''scratchpad''

This stores information about a particular classifier. For instance, the network and weights get stored here when using the backpropagation classifier (in the ''net'') field.

  * ''acts''

This is a matrix (''nOut'' x ''nTestTimepoints in this iteration'') containing all of the outputs from the classifier for each of the conditions at every test timepoint in this iteration

· ''perfmet'' and ''perf''

This is a structure containing the calculations required to calculate the [performance](#_Performance.md) of the classifier. There are multiple ways in this can be calculated, but all are required to contain a ''perf'' scalar. This ''perf'' scalar is duplicated in ''iterations(i).perf'' for convenience.

Multiple performance metrics can be used to calculate a performance value. If multiple performance metrics are applied to the same data, then the ''perfmet'' field is a cell array.

  * ''train\_idx'', ''test\_idx'', ''rest\_idx'', ''unknown\_idx''

These index vectors are derived from the cross-validation selector index that was used to decide which TRs would be used for training/testing in ''cross\_validation.m''.

TRs in the cross-validation selector index marked with 1s are included in ''train\_idx'', 2s in ''test\_idx'', 0s become ''rest\_idx'' and all other values go into the ''unknown\_idx''. Only ''train\_idx'' and ''test\_idx'' play any role in classification at all ' ''rest\_idx'' and ''unknown\_idx'' are only stored for completeness.

  * ''created''

As in the ''subj'' objects, this stores the arguments and function name used to create this object.

  * ''header''

More book-keeping information. You can add to the free-text narrative ''history'' field with [''add\_results\_history.m''](http://code.google.com/p/princeton-mvpa-toolbox/source/browse/trunk/core/subj/add_results_history.m).

There are no accessor functions (like ''get\_object.m'' or ''set\_mat.m'') for the results structure ' just edit it directly if you need to.

Finally, it is worth noting that ''results.total\_perf'' stores the mean of all the ''results.iterations(i).perfmet.perf'' values. If there are multiple perfmet objects, then ''results.total\_perf'' will be a vector.


[[Include(TroubleshootingClassification)]]


## Avoiding spurious classification ##

There are various ways in which one can fool oneself into thinking that above-chance classification means something.

For instance, if you're peeking (feeding your entire data set, including your test data, into your voxel selection method), then it's possible to classify complete nonsense better than chance (see [Peeking](#_Peeking.md)).

One essential check is to create a set of scrambled regressors that have the same properties as your real regressors, i.e. same number of TRs in each condition, balanced across runs etc. If the classifier consistently trains and generalizes with above-chance performance on testing data when you know that there is no regularity to the regressors, then it's back to the debugging drawing board. See [''scrambled\_regressors.m''](http://code.google.com/p/princeton-mvpa-toolbox/source/browse/trunk/core/preproc/scramble_regressors.m) for a way of easily shuffling the order of your timepoints within a run.

Note: there are various ways in which one could scramble/shuffle the regressors matrix. The provided method is the simplest one ' but for specific experiments or situations, other methods that preserve some of the properties of the data might be better.


## Further information ##

For further information, see the [Classification Howto's and occasionally-asked questions](#_Classification_1.md).