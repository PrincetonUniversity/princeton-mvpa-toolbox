# Princeton Multi-Voxel Pattern Analysis ' glossary #

See [Manual](Manual.md) (Data structures section) for more information on terms relating to the way the data is stored by the toolbox.





## block ##
A group of contiguous [TR](#TR.md) from the same [condition](#condition.md) in a particular [run](#run.md). Usually comprises multiple behavioral [trials](#trial.md).

## classification ##
In the machine learning sense, classification means taking a labelled training data set and showing the classifier algorithm examples of each condition over and over until it can successfully identify the training data. Then, the classifier's generalization performance is tested by asking it to guess the conditions of new, unseen data points.

See: [Classification](ManualClassification.md) in the manual.


## condition ##
The groups that you're trying to teach your classifier to distinguish, e.g. different tasks being performed by the subject in the experiment, or different stimuli being viewed.

## cross-validation ##
When you use n-minus-one/leave-one-out cross-validation classification, you iterate over your data multiple times. Each [iteration](#iteration.md) involves a fresh classifier [trained](#condition.md) on a subset of the data, and tested on the withheld data.

See: [N-minus-one (leave-one-out) cross-validation](ManualClassification#N-minus-one_(leave-one-out)_cross-validation.md)

## feature selection ##
Deciding which of your features (e.g. voxels) you want to include in your analysis.

## generalization ##
Testing the performance of a trained classifier on previously-unseen (test) data

## header ##
See: [Data structure ' Book-keeping and the headers](ManualDataStructures#Book-keeping_and_the_headers.md)

## history ##
A free-text field in the [header](#header.md) that gets automatically appended to, creating a sort of narrative of that object's role in the analysis.

See [Data structure ' Book-keeping and the headers](ManualDataStructures#Book-keeping_and_the_headers.md)

## iteration ##
Running the classifier once, using a particular subset of the data for testing, and the remainder for training. For example, you have 10 runs, you'll have 10 iterations, each time withholding a different run as the testing data.

See: [n minus one cross validation](#n_minus_one_cross_validation.md)

## leave-one-out ##
We use 'leave-one-out' and 'n-minus-one' interchangeably to refer to the [cross-validation](#cross-validation.md) procedure that leaves out a different subsection (e.g. [run](#run.md)) of the data each [iteration](#iteration.md).

## mask ##
A boolean 3D (or maybe 2D) single-TR volume indicating which voxels are to be included.

See [Data structure ' masks](#mask.md).

## name ##
Every [object](#object.md) in the [\_subj\_](#subj.md) structure has a name. This is a very important field, since it is used whenever accessing that object. The user is advised to refrain from accessing objects directly (e.g. subj.patterns{1}).

See: [Data structure ' innards of the \_subj\_ structure](#The_innards_of.md) and [Advanced ' accessing \_subj\_ directly](#Accessing_the_subj.md)

## n minus one cross validation ##
We use 'leave-one-out' and 'n-minus-one' interchangeably to refer to the [cross-validation](#_cross-validation.md) procedure that leaves out a different subsection (e.g. [run](#run.md)) of the data each [iteration](#iteration.md).

## object ##
An example of one of the [4 main data types](#Data_structure.md), e.g. a single cell in _subj_._patterns_ or _subj.masks_. Contains a _mat_ field with all the data, as well other required fields such as [name](#name.md), group\_name, derived\_from, [header](#header.md) etc.

See: [The innards of the subj structure](#The_innards_of.md)

## one-of-n ##
In this toolbox, this tends to refer a regressors matrix, to the idea that only a single condition can be active at any timepoint. This makes sense for basic/standard classification ' each timepoint belongs to one or other of the conditions, but not more than one at once.

Convolving regressors with a hemodynamic response function will lead to continuous-valued regressors, which may overlap (i.e. more than one condition may be non-zero at a given timepoint), which may violate some functions' one-of-n requirements.

[Check\_1ofn\_regressors.m](http://code.google.com/p/princeton-mvpa-toolbox/source/browse/trunk/core/util/check_1ofn_regressors.m) allows you to test whether a matrix is one-of-n.

## pattern ##
A (features x timepoints) matrix, usually of voxel activities, but could also be PCA components, wavelet coefficients, GLM beta weights or a statmap.

See: [Data structure ' patterns](#pattern.md).

## peeking ##
When you use your testing data set to help with voxel selection. Basically, this is a kind of cheating, and spuriously/illegitimately improves your classification by some margin.

See: [Manual](Manual.md).

## performance ##
The performance metric measures the similarity between the output produced by a classifier to the output it's supposed to produce.

See [Performance](ManualClassification#Performance.md) in the Classification section of the manual.

## Pre-Classification ##
By this, we mean the normalization and feature selection steps that go on before after the data structure has been created but before beginning classification, e.g. [zscore\_runs.m](http://code.google.com/p/princeton-mvpa-toolbox/source/browse/trunk/core/preproc/zscore_runs.m) and [feature\_select.m](http://code.google.com/p/princeton-mvpa-toolbox/source/browse/trunk/core/preproc/feature_select.m).

See [pre-classification](ManualPreClassification.md).

## regressors ##
For our purposes, the term 'regressors' refers to a set of values for each TR that denote the extent to which each condition is active. Used by statistical tests, and also as the teacher signal for the classifiers.

See: [Data structure ' regressors](ManualDataStructures#Regressors.md).

## results ##
This is where all the information about [classification](#_condition.md) is stored.

See: [Classification ' results structure](ManualClassification#The_results_structure.md).

## run ##
A single scanning session. There are usually a handful of runs in a given hour-long experiment.

## selector ##
A set of labels for each [TR](#_TR.md), e.g. where all the [runs](#_run.md) start and finish, or which TRs should be used for [training](#_condition.md) and which for testing on this [iteration](#iteration.md).

See: [Data structure ' selectors](ManualDataStructures#Selectors.md).

## statmap ##
The result of some kind of statistical test, usually performed separately for each voxel. For instance, the ANOVA yields a statmap of p values, one for each voxel. Each p value denotes the probability that that voxel varies significantly between conditions.

Statmaps are stored as patterns, since the term 'mask' is usually used to refer to a boolean 3D volume.

A mask can be created from a statmap by choosing all the voxels that are above/below some threshold.

See [Data structure ' masks](ManualDataStructures#Masks.md) and [Pre-classification ' Statmaps](ManualPreClassification#Statmaps.md).

## subj ##
See: [Data structure ' selectors](ManualDataStructures#Selectors.md).

## testing ##
Presented a [trained](#training.md) classifier with patterns that it has never seen before, and testing its performance.

## TR ##
Stands for 'time to repetition'. Basically, the time taken for the scanner to acquire a single 3D brain volume. We often use it (somewhat imprecisely) to mean a single timepoint (usually of about 2s).

## training ##
Showing a classifier lots of examples of a person's brain in condition A, and telling it each time, 'This is an example of the brain in condition A'. We then show it lots of examples of the same brain in condition B, also telling it which condition these brain examples came from. This process repeats until the classifier has learned which are which.

In reality, the examples tend to be interleaved with each other and presented in a different order each time. Most classifier algorithms can also deal with more than just two categories.

## trial ##
A behavioural trial in the experiment, that probably spans multiple [TR](#TR.md)s. Multiple trials make up a [block](#block.md).

## voxel selection ##
Whenever you apply a _mask_ to a _pattern_, you are selecting voxels. This term tends to be used more often in the machine learning context of 'feature selection' ' choosing which of the features (voxels) contain signal for the classification problem you are attempting.

See: 'Pre-classification ' Anova' in the [Manual](Manual.md).