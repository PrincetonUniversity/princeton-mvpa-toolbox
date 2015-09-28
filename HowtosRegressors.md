# Howtos #

## Regressors ##

### How can I exclude conditions from my analysis ###

See: Howtos / [Pre-classification How can I exclude conditions from my analysis](HowtosPreClassification#How_can_I_exclude_conditions_from_my_analysis.md)


### How can I exclude timepoints from my analysis ###

See Howtos / [Pre-classification / How can I handpike timepoints to exclude?](HowtosPreClassification#How_can_I_handpick_timepoints_to_exclude_from_my_analysis.md)


### How can I take the haemodynamic lag into account ###

The peak haemodynamic response is estimated to lag about five seconds behind stimulus onset.

1. The very simplest way to take this into account is to shift the regressors matrix a few timepoints along relative to the data, so that the stimulus onset as coded by your regressors aligns with the peak BOLD response in the data. See [can I shift my regressors along](How.md).

2. Better still, you can convolve your regressors matrix with a model of the haemodynamic response function, and then use something like a general linear model to pull out the relative contributions of each condition to the data. See [How can I convolve my regressors with a haemodynamic response function](HowtosRegressors#How_can_I_convolve_my_regressors_with_a_haemodynamic_response_fu.md)


### How can I shift my regressors along ###

See [How can I take the haemodynamic lag into account](HowtosRegressors#How_can_I_take_the_haemodynamic_lag_into_account.md) for background.

[Shift\_regressors.m](http://code.google.com/p/princeton-mvpa-toolbox/source/browse/trunk/core/preproc/shift_regressors.m) will move the regressors matrix along, snipping off the last few TRs at the end of each run, and zero-padding the very beginning of each run with rest volumes. Assuming a TR (time to repetition) of 2 seconds, then shifting by 3 timepoints is probably about right.

```
 >> subj = shift_regressors(subj,'conds','runs',3);
```

This will create a new regressors object called shift the regressors in the conds object by three timepoints, within each run indexed in the _runs_ selector object. That is, it will add three rest TRs at the beginning of each run, shifting everything along by three, then then truncate the end by three to leave it the same size.

If for some reason you wanted to shift the entire regressors matrix along by n timepoints, regardless of which run things came from (probably a bad idea), then just use an all-ones selector instead of a runs selector.

For the most part, we recommend [convolving the regressors with a haemodynamic response function](HowtosRegressors#How_can_I_convolve_my_regressors_with_a_haemodynamic_response_fu.md) and using something like multiple regression for voxel selection. However, if you want to use an ANOVA for your voxel selection, then you need your regressors to be in binary, 1-of-n form, and shifting may be the only option.

See [tutorial\_hard / Shifting the regressors along.](TutorialAdv#Shifting_the_regressors_along.md)


### How can I convolve my regressors with a haemodynamic response function ###

See [How can I take the haemodynamic lag into account](HowtosRegressors#How_can_I_take_the_haemodynamic_lag_into_account.md).

The more principled alternative to shifting the regressors is to convolve them with a model of the haemodynamic response function, such as the gamma-variate model used by AFNI's _waver_ function. You can do this yourself easily enough if you already have your regressors stored in _.1d_ files. The [convolve\_regressors\_afni.m](http://code.google.com/p/princeton-mvpa-toolbox/source/browse/trunk/core/preproc/convolve_regressors_afni.m) function writes out a regressors object to separate _.1d_ files, one for each run for each condition, calls the _waver_ function to create new convolved _.1d_ files, reads them in and concatenates them to create a new regressors object, e.g.

```
 >> subj = convolve_regressors_afni(subj,'conds','runs'); 
```

These convolved regressors can then be used for voxel selection, classification etc., though obviously they'll no longer be binary. This can make your life a little bit more complicated ' unless you have a slow block design with lots of rest between blocks, it won't be clearcut which conditions each timepoint belongs to any more. Such is life with fMRI. If you're planning to do basic classification, then you're going to have to decide what to do with these timepoints that belong to multiple conditions. Perhaps the simplest thing would be to throw out all the timepoints that belong to multiple conditions. Alternatively, you could use a classifier that will give you scalar-valued outputs (e.g. a neural network with a sigmoidal activation-function hidden layer and a linear activation-function output layer), and feed in the convolved regressors. You could also consider using the beta values from a GLM rather than the actual raw voxel data itself (see Haxby et al., 2001). In short though, if you want to do basic 1-of-n classification, slow block designs are much easier to analyze.

See [Tutorial Advanced / Convolving the regressors with a model of the haemodynamic response function](TutorialAdv#Convolving_the_regressors_with_a_model_of_the_haemodynamic_respo.md)