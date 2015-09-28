# Pre-classification #

By 'pre-classification' here, we mean everything that occurs between importing the data into Matlab (e.g. from AFNI) and running the classifier on it. Obviously, the basic pre-processing work that goes on even earlier than this (e.g. motion correction, detrending) is crucial too, but we only briefly discuss that here.

We have found that the right pre-classification normalization and and feature selection makes a large difference to classifier performance.


## Zscoring ##

Usually, we zscore over time. That is, we take an individual voxel's timecourse, and subtract the mean and divide by its standard deviation, leaving a linearly-transformed timecourse with mean 0 and standard deviation 1.

The ''zscore\_runs.m'' included in the toolbox actually treats each run as a separate timecourse. This was originally designed to account for possible baseline shifts between runs.

This will not remove linear or quadratic trends within runs.

At this point, the best method of zscoring the data is still unconfirmed. Doing some kind of zscoring appears to help a great deal with backpropagation and other classification methods though.

You may be better off using a tool like 3dDetrend, and just not putting the mean back in.

Requires the Matlab Statistics toolbox.


## Anova and voxel selection ##

If you feed all of the voxels in the brain into a classifier, performance will be poor, because many of the voxels will be uninformative. A good classifier will learn to ignore most of these, but its performance can be greatly facilitated by excluding all but a few that are likely to contain information.

The default voxel selection algorithm in the toolbox is [statmap\_anova.m](http://code.google.com/p/princeton-mvpa-toolbox/source/browse/trunk/core/preproc/statmap_anova.m). It operates on each voxel individually, assessing whether that voxel's activity varies significantly between conditions. To do this, it needs to know which pattern you want to select features from, a [one-of-n](Glossary#one-of-n.md) regressors matrix that shows which TRs belong to which conditions, and also a selectors matrix so that it knows which TRs to use (to avoid [peeking](Glossary#peeking.md)). It returns a statmap _pattern_ which can then be thresholded with [create\_thresh\_mask.m](http://code.google.com/p/princeton-mvpa-toolbox/source/browse/trunk/core/preproc/create_thresh_mask.m) to create a boolean 3D _mask_.

Running some kind of ANOVA or other voxel selection method tends to help a great deal. However, it is worth bearing in mind that creating a thresholded mask with a p threshold of 0.05 could still be allowing through thousands of spurious voxels, i.e. voxels which pass the anova by chance, and hence will disrupt generalization to the test data. Making the p threshold stricter makes statistical sense (though a Bonferroni correction may be too strict). However, even this may not be the solution if this is partly due to spikes of noise that make the voxel appear to vary significantly across conditions. Adding runs in as a factor may help (planned in the future).

All of the discussion above centres on choosing voxels. However, your patterns could equally contain principal components, wavelet coefficients or stockmarket prices ' the principle idea that you need to exclude uninformative features still holds, and an ANOVA should still work reasonably well.

We recommend writing your statmaps out as BRIK files so that you can view them in AFNI. If your statmaps for different iterations look different, or if you're getting homogenous speckling throughout the brain, then you're probably going to get poor classification generalization.

Note: if you are going to use the ANOVA and boxcar regressors, you'll need to shift them along ([shift\_regressors.m](http://code.google.com/p/princeton-mvpa-toolbox/source/browse/trunk/core/preproc/shift_regressors.m)) by about 3 timepoints relative to your data in order to take account of the haemodynamic response lag.

Note: _statmap\_anova.m_ requires the Matlab [Statistics toolbox](http://www.mathworks.com/products/statistics/).


## Other voxel selection methods ##

We are actively investigating alternative voxel selection methods. We would recommend using 3dDeconvolve (or some other multiple regression technique) rather than the ANOVA, since then you can convolve your regressors, rather than simply shifting them. We have an internal statmap\_3dDeconvolve.m function that can be used to call 3dDeconvolve in an n-minus-one style ' [contact us](ContactDetails.md) if this interests you.


## Statmaps ##

By statmap, we mean the result of some kind of statistical test, usually performed separately for each voxel. For instance, the ANOVA yields a statmap of F (or p) values, one for each voxel. Each p value denotes the probability that that voxel varies significantly between conditions.

Statmaps are stored as patterns (_nActiveVox_ x _1_). We considered storing statmaps as mask objects, but we decided that the term 'mask' is usually used to refer to a boolean 3D volume, and so it would be confusing to store a continuous values in an object called 'mask'.

A mask can be created from a statmap by choosing all the voxels that are above/below some threshold using the [create\_thresh\_mask.m](http://code.google.com/p/princeton-mvpa-toolbox/source/browse/trunk/core/preproc/create_thresh_mask.m) or the n best voxels using [create\_sorted\_mask.m](http://code.google.com/p/princeton-mvpa-toolbox/source/browse/trunk/core/preproc/create_sorted_mask.m).


### Creating your own statmap ###

If you want to create your own statmap, start by looking at the default [statmap\_anova.m](http://code.google.com/p/princeton-mvpa-toolbox/source/browse/trunk/core/preproc/statmap_anova.m), and the [statmap\_template.m](http://code.google.com/p/princeton-mvpa-toolbox/source/browse/trunk/core/template/statmap_template.m) template.

Also, see the [requirements for custom functions that modify the subj structure](#_Requirements_for_custom.md).

Here are the requirements, based on _statmap\_anova.m_:

· returns the modified _subj_ structure

· takes in a _subj_ structure argument

· takes in a pattern name argument (_data\_patname_) whose features you want to select from

· takes in a regressors name argument (regsname), which you want to use to decide whether features are significant ' all conditions get used

· takes in a selector name argument (selname) to determine which TRs from the pattern should be employed ' the _statmap\_anova.m_ only uses 1s. 2s mark the withheld testing run. 3s are reserved for validation vectors and 0s for rest. Use a code value besides these if you need your selectors to highlight other subsets of timepoints

· takes in a string argument to name the new statmap pattern that will be created (new\_map\_patname)

· takes in a bonus argument extra\_arg that you can use for any extra arguments that you need

· it should create a new statmap pattern object called new\_map\_patname (and describe this in the help comments)

· add any extra\_arg information to the created field (see the call to add\_created.m in zscores\_run.m, for example)

· there's no need for it to display to the terminal, because the caller function (e.g. feature\_select.m) should do that for you

· optionally add a description sentence to the header.history cell array for future reference

If you think these restrictions are too strict and don't fit with a statmap function that you might want to use, you could either ignore the arguments you don't need, or [let us know](ContactDetails.md) and we'll consider modifying the interface.


## Peeking ##

Peeking is when you use your testing data set to help with voxel selection. Basically, this is a kind of cheating, and spuriously/illegitimately improves your classification by some margin.

The toolbox makes it easy to avoid peeking. Run [create\_xvalid\_indices.m](http://code.google.com/p/princeton-mvpa-toolbox/source/browse/trunk/core/preproc/create_xvalid_indices.m) to create a group of selectors, one for each iteration of your n-minus-one cross-validation. Then call [feature\_select.m](http://code.google.com/p/princeton-mvpa-toolbox/source/browse/trunk/core/preproc/feature_select.m), which in turn calls statmap\_anova.m (or any other voxel selection method) multiple times, once per iteration, using a different subset of the _pattern_ data each time. This will yield a group of _masks_, the same size as the group of _selectors_, which can then be used to restrict which voxels get fed to the classifier separately for each iteration of the n-minus-one.

Using the same group of _selectors_ for both voxel selection and classification ensures that a TR cannot simultaneously be part of the voxel selection training data ''and'' be part of the withheld testing data.

It is possible to circumvent this anti-peeking machinery by calling _[statmap\_anova.m](http://code.google.com/p/princeton-mvpa-toolbox/source/browse/trunk/core/preproc/statmap_anova.m)_ directly with _[peek\_anova.m](http://code.google.com/p/princeton-mvpa-toolbox/source/browse/trunk/core/preproc/peek_feature_select.m)_, but obviously this is not recommended for any analysis that is intended for publication.

To see how peeking can artificially boost your performance, try [scrambling your regressors](#_Avoiding_spurious_classification.md) using _[scramble\_regressors.m](http://code.google.com/p/princeton-mvpa-toolbox/source/browse/trunk/core/preproc/scramble_regressors.m)_.


## Further information ##

For further information, see the [Pre-classification Howto's and occasionally-asked questions](HowtosPreClassification.md).