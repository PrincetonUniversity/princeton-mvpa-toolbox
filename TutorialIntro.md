# Introductory tutorial #





---


## Introduction ##

This tutorial will run through the basics of a single within-subject analysis, classifying fMRI brain states into different conditions using the multi-voxel pattern analysis methods. It assumes that you have read and carried out the [Setup](Setup.md).

Specifically, this analysis will use an AFNI dataset from Haxby et al (Science, 2001) that is provided with the toolbox, in which participants viewed different classes of visual objects. The goal of the analysis is to classify the distributed patterns of neural activity in order to predict psychological states (i.e., viewing a face) from the neural state (e.g., BOLD pattern in ventral temporal cortex).

If you're interested in ANALYZE/SPM import/export rather than AFNI, see TutorialIntroSPM.

The Matlab code described below is reproduced from [tutorial\_easy.m](http://code.google.com/p/princeton-mvpa-toolbox/source/browse/trunk/core/tutorial_easy.m), which contains briefer inline comments than this narrative. For further information, see the main documentation in the [Manual](Manual.md) or the [Glossary](Glossary.md) for unfamiliar terms.

We called this document ''tutorial\_easy.htm''. Don't let that fool you. We've really done everything we can to trip you up with it. Just wait till you try TutorialAdv. It's so difficult and scary that small children will cry around the globe whenever a copy is downloaded. In the meantime, let us begin.


## What you will need to start with ##

Here's what you need to run this tutorial (all of which should be included in the scripts and data tarballs in the [Downloads Tab](Downloads.md)):

  * a working copy of Matlab (ideally [R14](https://code.google.com/p/princeton-mvpa-toolbox/source/detail?r=14) or more recent - see 'Compatibility' section in the [Manual](Manual.md))

  * all of the .m files included in the main toolbox download (including [tutorial\_easy.m](http://code.google.com/p/princeton-mvpa-toolbox/source/browse/trunk/core/tutorial_easy.m))

  * the sample dataset in AFNI format - ''haxby8\_r[1..10]+orig.BRIK'' and ''.HEAD''

  * regressors information - ''tutorial\_regs.mat''

  * runs information - ''tutorial\_runs.mat''

  * a mask in AFNI format - ''mask\_cat\_select\_vt+orig.BRIK'' and ''.HEAD''

Finally, you'll need all your paths to be set up properly, and to be in the right directory when you load up Matlab. See the 'Installation' section in the [Manual](Manual.md) for more information about this.


## The Haxby 8 categories experiment ##

The subject in this experiment viewed lots of exemplars of 8 different types of images.

Each run contained a 9-TR block for each condition with rest in between and at either end. There are 10 runs of a single subject included in the dataset in this toolbox.

Note that the individual stimulus presentations within a given category block might not align with the TRs.

See the 'Sample data set' section in the [Manual](Manual.md) for more information.


## The easy-like-sunday-morning tutorial ##

The goal of this analysis is to teach a classifier to predict which class of object the subject is viewing on each trial. To do this, we need several bits of information:

  * a ''pattern'' to classify

The BOLD data itself, stored in AFNI's .BRIK/.HEAD format.

  * a set of ''regressors''

A matrix of condition labels (one row per condition) that identify each volume in the data. This is necessary for training the classifier.

  * a ''selector''

When dealing with classifiers, one cannot train and test the classifier on the same data. Doing so would lead to artifically inflated accuracy. So we will need a set of selectors that indicate which timepoints should be used for testing and which should be used for training.

  * a ''mask''

We don't want to include all the voxels from the brain in our analysis. We use boolean 3D spatial masks to label the voxels we want to keep and the voxels we want to exclude.


### Initializing the subject (''subj'') structure ###

This toolbox uses a single monolothic structure to house all of these types of information for an individual subject. As this is the main structure for each subject, we'll call it the ''subj'' structure.

Our analysis will begin by creating a subject structure, and loading the patterns, selectors, regressors and masks we need. Later, we will run the actual analysis by passing the subject structure to the classifier and supporting functions.

To initialize it for use with the toolbox, we need to specify what we're going to call the experiment ('haxby8') and a unique identifier for the subject ('tutorial\_subject'):

```
 >> subj = init_subj('haxby8','tutorial_subj');

>> summarize(subj);

Subject 'tutorial_subj' in 'haxby8' experiment

No pattern objects

No regressors objects

No selector objects

No mask objects 
```

This displays the contents of our new subject structure.

Eventually, you will have multiple objects in your structure of each type. For instance, once you've loaded in an AFNI dataset and z-scored it, you'll have two patterns. There is no limit to the number of objects of each type that can be contained within the subj structure.


### Ventral temporal with GLM mask ###

Before loading in our data, we first need to create a ''mask'' to restrict the voxels we want to allow through:

```
>> subj = load_afni_mask(subj,'VT_category-selective','mask_cat_select_vt+orig');

Setting all non-zero values in the mask_cat_select_vt+orig.BRIK mask to one

Mask 'VT_category-selective' created by load_afni_pattern
```

This simply initializes a ''mask'' object called 'VT\_category\_selective' by loading in the AFNI files called ''mask\_cat\_select\_vt+orig.BRIK ''and ''.HEAD''.

Note: this mask happens to be an anatomically-defined ventral temporal mask that has already had a GLM applied to further restrict the voxels. We're using this just to whittle down the number of voxels so that the tutorial runs quickly, but it isn't really scientifically legitimate (see [Manual](Manual.md) / Pre-classification / Peeking'' for more information). For a real analysis, you'd want to create your masks with the toolbox to avoid peeking (see the 'peeking' section in the [Manual](Manual.md)). See ''tutorial\_hard.htm'' for information on creating intra-cranial and whole-volume masks.

To see how the ''subj ''structure looks now that the mask object has been added:

```
 >> summarize(subj)

Subject 'tutorial_subj' in 'haxby8' experiment

No pattern objects

No regressors objects

No selector objects

Masks - [ X x Y x Z ] [ nVox] 

1) VT_category-selective - [ 64 x 64 x 40] [ 577]
```

You may have to widen this window in order to stop the lines from wrapping round messily.

If we want to examine our handiwork, we can see how the mask object is stored:

```
 >> mask = get_object(subj,'mask','VT_category-selective') 

mask =

name: 'VT_category-selective'

header: [1x1 struct]

mat: [64x64x40 double]

matsize: [64 64 40]

group_name: ''

derived_from: ''

created: [1x1 struct]

thresh: NaN

nvox: 577

last_modified: '050821_1812_11' 
```

The ''mat'' field is the key to all the objects. In the case of a mask, it's a boolean 3D volume. Only voxels with a 1 in this matrix will be loaded in from the data in the next step. We'll ignore all the other fields for now, and come back to them later.

N.B. At various stages, fields like 'last\_modified' will contain date and time information in YYMMDD\_HHMM\_SS format. The information on your screen will obviously be different from that presented here.

### EPI pattern ###

Loading in the data is almost as simple. We're going to create a ''pattern'' object called 'epi' to store our raw EPI voxel data. This pattern is only going to include voxels that were allowed through by the mask we just created called 'VT\_category-selective'.

Because your data may be big and stored in multiple AFNI BRIK/HEAD file pairs, ''load\_afni\_pattern.m'' takes a cell array of strings as its ''filenames'' argument (ignoring the ''.BRIK'' extention). We will create this list first.

```
 >> for i=1:10 

raw_filenames{i} = sprintf('haxby8_r%i+orig',i);

end

>> subj = load_afni_pattern(subj,'epi','VT_category-selective',raw_filenames); 

Starting to load AFNI pattern from 10 BRIK files

1 2 3 4 5 6 7 8 9 10

Pattern 'epi' created by load_afni_pattern
```

Note: this can take a little while for large datasets, even if most of the voxels are being masked away. It will also take up lots of RAM while it's loading - as a general rule of thumb, having twice as much RAM as the biggest object that you need to manipulate is the bare minimum that is usable. Reading it in one run at a time helps greatly, as can masking which voxels are included.

Now the ''subj'' structure has now been updated with a new ''pattern'' object:

```
 >> summarize(subj)

Subject 'tutorial_subj' in 'haxby8' experiment

Patterns - [ nVox x nTRs]

1) epi - [ 577 x 1210]

No regressors objects

No selector objects

Masks -  [ X x Y x Z ] [ nVox]

1) VT_category-selective - [ 64 x 64 x 40] [ 577] 
```

Let's look at the contents of this new pattern object:

```
 >> pats = get_object(subj,'pattern','epi') 

pats =

name: 'epi'

header: [1x1 struct]

mat: [577x1210 double]

matsize: [577 1210]

group_name: ''

derived_from: ''

created: [1x1 struct]

masked_by: 'VT_category-selective'

last_modified: '050821_1815_45' 
```

This ''pattern'' object is broadly similar to the mask object. Only 577 voxels were allowed through the mask (which corresponds to the number of non-zero points in the 3D boolean mask), and there are 1210 TR timepoints.

One main difference between the mask and pattern is that the values (for the raw EPI voxel activities) are stored as a 2D matrix (''voxels x timepoints'') in the ''mat'' field. The 3D information about their location has been discarded to make manipulating the data easier and more memory-efficient.

However, notice that the name of the mask used to decide which voxels are allowed through is stored in the 'masked\_by' field. This is essential, because when you decide that you do want to know where a voxel sits inside the brain, or even identify which voxel is which between differently-masked patterns, you'll need to refer to their position in the 3D volume in the mask ''mat'' that was used to create them. This is discussed in the 'Advanced - Figuring out which voxel is which, and where' section in the [Manual](Manual.md).

### Condition regressors ###

We're going to start by loading in our regressors matrix from a pre-prepared file. The regressors matrix stores information about which conditions each TR belongs to. It's like the regressors matrix that a GLM would use. We will give this set of regressors the name 'conds'. We will need the regressors later for training our classifier about which TRs are which.

```
>> subj = init_object(subj,'regressors','conds');
```

The ''mat'' field is empty initially, so let's load in the actual regressors matrix we're going to use from the pre-prepared ''tutorial\_regs.mat'' file.

```
>> load('tutorial_regs');
```

This will load in a variable called ''regs'' which is just a matrix of conditions x timepoints (8 x 1210).

```
 >> whos regs 

Name Size Bytes Class

regs 8x1210 77440 double array

Grand total is 9680 elements using 77440 bytes 
```

Don't worry if the byte sizes of your variables are slightly different.

Now, we're going to store the matrix that we just loaded inside our newly-initialized ''regressors'' object.

```
>> subj = set_mat(subj,'regressors','conds',regs);
```

Finally, let's just append some information about the 8 conditions in this regressors matrix.

```
>> condnames = {'face','house','cat','bottle','scissors','shoe','chair','scramble'};

>> subj = set_objfield(subj,'regressors','conds','condnames',condnames);
```

This latter command just appended the ''condnames'' cell array of strings to a field called 'condnames' in the regressors object called 'conds'. Let's put that in the order the arguments appear in the function: we have a subject structure called ''subj'', which contains a ''regressors'' object called ''conds'', which contains a field called ''condnames'', into which we want to put the contents of our variables 'condnames'. Note that the variable 'condnames' and the field 'condnames' don't have to have the same name, but it's often easier to tell what's what if they do.

Let's make things a bit more concrete by examining our newly-created regressors object:

```
>> condsobj= get_object(subj,'regressors','conds') 

condsobj =

name: 'conds'

header: [1x1 struct]

mat: [8x1210 double]

matsize: [8 1210]

group_name: ''

derived_from: ''

created: [1x1 struct]

condnames: {1x8 cell}

last_modified: '050821_1821_09' 
```

As noted, all objects have a ''mat'' field which stores their main data, and suitably, this is where the regressors matrix has now been stored. As expected, there are 8 conditions. Note that, like the ''epi'' pattern, the regressors matrix stores time on the 2nd dimension, and that again there are 1210 TRs for this experiment.

Depending on the size of your screen, the ''condnames'' cell array may show the condition names that have been stored, or it might just show that there are 8 string cells.

### Runs selector ###

Now, we're going to repeat the same process to store information about which of the 10 runs (i.e. scanning sessions) each TR came from. This is stored simply as a row-vector with the same number of timepoints as the regressors, containing 1s, 2s, 3s, etc. This goes in a ''selector'' object (think of these as a set of 'timelabels'), which we'll call 'runs':

```
>> subj = init_object(subj,'selector','runs'); 

>> load('tutorial_runs'); 

>> subj = set_mat(subj,'selector','runs',runs); 
```

The newly-created selectors object looks very similar to the other objects:

```
>> runs = get_object(subj,'selector','runs') 

runs =

name: 'runs'

header: [1x1 struct]

mat: [1x1210 double]

matsize: [1 1210]

group_name: ''

derived_from: ''

created: [1x1 struct]

last_modified: '050821_1823_27' 
```

Try examining the contents of the ''runs'' selector matrix yourself (the 1x1210 ''mat'' field) as before, using:

```
>> runs = get_mat(subj,'selector','runs');
```

You should see that it contains 1210 integer labels, one for each TR, identifying which scanning run that TR came from.


### Waypoint before further pre-classification steps ###

At this point, we've loaded everything in, and we're ready to start the pre-classification steps.

By now, your subj structure should look much busier:

```
>> summarize(subj)

Subject 'tutorial_subj' in 'haxby8' experiment

Patterns - [ nVox x nTRs]

1) epi  - [ 577 x 1210]

Regressors - [nCond x nTRs]

1) conds - [ 8 x 1210]

Selectors -  [nCond x nTRs]

1) runs - [ 1 x 1210]

Masks - [ X x Y x Z ] [ nVox] 

1) VT_category-selective - [ 64 x 64 x 40] [ 577] 
```

We're now ready to transform and slim this data down before passing it into the classifier.


### Zscoring ###

It helps to zscore the data by subtracting out the mean of each voxel's timecourse and scaling it so that the standard deviation of the timecourse is one.

''zscore\_runs.m'' actually treats each run as a separate timecourse, which can help remove any between run differences due to baseline shifts.

It takes in the name of the pattern you want to zscore, and also the selector name that contains the runs information, so that it knows how to zscore each run separately.

```
>> subj = zscore_runs(subj,'epi','runs');
```

Beginning zscore\_runs - max\_runs = 10

1 2 3 4  5 6 7 8 9 10

Pattern 'epi\_z' created by zscore\_runs

This step requires the ''zscore.m'' function included in the Matlab Statistics toolbox. If you ''don't'' have the Stats toolbox, then you can use the MVPA home-grown version in its place, which is less clever but should do the job for now:

```
>> subj = zscore_runs(subj,'epi','runs','use_mvpa_ver',true);
```

You can check with the ''summarize'' function that it has indeed created a new ''epi\_z'' pattern of the same size as ''epi\_z''.

```
>> summarize(subj,'objtype','pattern') 

Subject 'tutorial_subj' in 'haxby8' experiment

Patterns - [ nVox x nTRs]

1) epi - [ 577 x 1210]

2) epi_z  - [ 577 x 1210] 
```

Calling ''summarise.m'' with the 'objtype' and 'pattern' pair of arguments is useful if you only want to see one type of object. Many of the toolbox scripts allow optional property/value pairs of arguments like this.

You could even try looking to see how the data has changed by comparing the data before and after:

```
>> before_zscore_mat = get_mat(subj,'pattern','epi'); 

>> after_zscore_mat = get_mat(subj,'pattern','epi_z'); 
```


### Creating the cross-validation indices ###

This next step is essential, but not as transparent. We are going to create a group of selectors in anticipation of the n-minus-one cross-validation scheme that we will use to train and test our classifier.

We have 10 runs, so our cross-validation will have 10 iterations. Each iteration will involve training a fresh classifier on most of the data (9 of the 10 runs), and testing on that lonely, withheld run. As a result, every timepoint gets used as training data in 9 of the iterations and as testing data in one of them.

We are going to create each member of the group of 10 selectors to act as a kind of temporal mask for one of the iterations.

See the 'Classification - n-minus-one (leave-one-out) cross-validation' section in the [Manual](Manual.md) for a more extensive explanation of what's going on.

The only information needed for this is the ''runs'' selector. As a result, the group we're going to create will automatically be named 'runs\_xval', and its members will be individually named 'runs\_xval\_1', 'runs\_xval\_2' etc.

```
>> subj = create_xvalid_indices(subj,'runs');

Selector group 'runs_xval' created by create_xvalid_indices
```

Call ''summarize.m'' on the ''subj'' structure to see that it has added lots of new selectors:

```
>> summarize(subj,'objtype','selector')

Subject 'tutorial_subj' in 'haxby8' experiment

Selectors - [nCond x nTRs]

1) runs - [ 1 x 1210]

2) runs_xval_1 - [GRP size 10] [ 1 x 1210]

3) runs_xval_2 - [GRP size 10] [ 1 x 1210]

4) runs_xval_3 - [GRP size 10] [ 1 x 1210]

5) runs_xval_4 - [GRP size 10] [ 1 x 1210]

6) runs_xval_5  - [GRP size 10] [ 1 x 1210]

7) runs_xval_6 - [GRP size 10] [ 1 x 1210]

8) runs_xval_7 - [GRP size 10] [ 1 x 1210]

9) runs_xval_8 - [GRP size 10] [ 1 x 1210]

10) runs_xval_9 - [GRP size 10] [ 1 x 1210]

11) runs_xval_10 - [GRP size 10] [ 1 x 1210] 
```

You can even peer at each selector individually, e.g.

```
>> xval1 = get_object(subj,'selector','runs_xval_1')

xval1 =

name: 'runs_xval_1'

header: [1x1 struct]

mat: [1x1210 double]

matsize: [1 1210]

group_name: 'runs_xval'

derived_from: 'runs'

created: [1x1 struct]

last_modified: '050821_1826_07' 
```

We can see that it has been individually named as we expected, and its group\_name allows us to treat all 10 together later. We can also see in the 'derived\_from' field that this object was based on the 'runs' selector.

Let's look at the first couple of hundred of items in the ''mat'' for this selector:

```
>> xval1_mat = get_mat(subj,'selector','runs_xval_1');
```

```
>> xval1_mat(1:200)

ans =

Columns 1 through 14

2 2 2 2 2 2 2 2 2 2 2 2 2 2

Columns 15 through 28

2 2 2 2 2 2 2 2 2 2 2 2 2 2

Columns 29 through 42

2 2 2 2 2 2 2 2 2 2 2 2 2 2

Columns 43 through 56

2 2 2 2 2 2 2 2 2 2 2 2 2 2

Columns 57 through 70

2 2 2 2 2 2 2 2 2 2 2 2 2 2

Columns 71 through 84

2 2 2 2 2 2 2 2 2 2 2 2 2 2

Columns 85 through 98

2 2 2 2 2 2 2 2 2 2 2 2 2 2

Columns 99 through 112

2 2 2 2 2 2 2 2 2 2  2 2 2 2

Columns 113 through 126

2 2 2 2 2 2 2 2 2 1 1 1 1 1

Columns 127 through 140

1 1 1 1 1 1 1 1 1 1 1 1 1 1

Columns 141 through 154

1 1 1 1 1 1 1 1 1 1 1 1 1 1

Columns 155 through 168

1 1 1 1 1 1 1 1 1 1 1 1 1 1

Columns 169 through 182

1  1 1 1 1 1 1 1 1 1 1 1 1 1

Columns 183 through 196

1 1 1 1 1 1 1 1 1 1 1 1 1 1

Columns 197 through 200

1 1 1 1 
```

We can see an unhelpful bunch of '2's and '1's. Think of this as a kind of code. '1's signify TRs that will be used as training data for the classifier for this iteration of the n-minus-one cross-validation. These '1' TRs will also be the timepoints that the ANOVA uses to create its statmap for this iteration. The '2's will be ignored by the ANOVA, and will become the testing data for the classifier when assessing its generalization to unseen data. In other words, for the selector shown above, the first 121 TRs are going to be withheld as testing ('2' ) TRs for this iteration, while the rest will be training ('1') TRs.

If you look at the contents of different selector indices from the newly-created 'runs\_xval' group, you will see that a different run's worth of TRs are coded with '2's as testing data each time, while all the rest are training '1's. Any TRs labelled with anything but '1' or '2' will be completely ignored by the functions from now on.


### ANOVA ###

Before actually doing the classification, it usually helps to throw away uninformative voxels. In the machine learning literature, this is termed 'feature selection'.

The easiest way to do this is to use an ANOVA which tells you the probability that a given voxel's activity varies significantly between conditions over the course of the experiment. Note that this ANOVA method runs completely separately for each voxel, yielding a p value for each.

We will store the statmap of p values from the ANOVA as a pattern. We can then create a mask from that statmap of just those voxels which vary significantly between conditions (above a certain threshold probability).

This whole business is unfortunately made more complicated, because it would be cheating (also termed 'peeking') if the ANOVA was run on timepoints that will later be used to test the classifier. Think of it this way - if you pass your entire data set through the ANOVA and remove all but the voxels that vary significantly across conditions, then this will definitely help classification. But that's because you've only fed your classifier features that you ''know'' will help with generalization, because you used your test data set during feature selection. The solution is to ensure that you run the ANOVA on only those TRs that your classifier will be trained on later. Since there are going to be multiple iterations, each with a fresh classifier, you're going to need to run the ANOVA multiple times, yielding a separate mask for each iteration.

Fortunately, the ''feature\_select''''.m'' function will do all of that for you. We want it to choose the features from our ''epi'' data pattern that vary between the conditions in ''conds'', using the ''runs\_xval'' group of selector indices that we just created to decide which TRs to use for each iteration.,,,,

```
>> subj = feature_select(subj,'epi_z','conds','runs_xval')

Starting 10 anova iterations

1 2 3 4 5 6 7 8 9 10 
```

Pattern statmap group 'epi\_z\_anova and mask group 'epi\_z\_thresh0.05' created by feature\_select

This requires the Stats toolbox to call ''anova1.m''. If you don't have the toolbox, you can use the toolbox's home-grown alternative, which may actually be faster (because it does the anova on many voxels at once), though it's probably slightly less clever. This is how to do that - it takes advantage of the toolbox's extensible architecture to plug in a different ANOVA function, which involves a slightly more convoluted syntax. See 'Creating custom functions' in the [Manual](Manual.md) for further information.

```
>> statmap_arg.use_mvpa_ver = true;

>> subj = feature_select(subj,'epi_z','conds','runs_xval','statmap_arg',statmap_arg); 
```

Now try calling the ''summarize'' function. Things are getting crowded, so let's just show the group names (rather than all of the individual members):

```
>> summarize(subj,'display_groups',false)

Subject 'tutorial_subj' in 'haxby8' experiment

Patterns -                                              [ nVox x nTRs]
    1) epi                            -                 [  577 x 1210]
    2) epi_z                          -                 [  577 x 1210]
 3-12) epi_z_anova                    *   [GRP size 10] [  577 x    1]

Regressors -                                            [nCond x nTRs]
    1) conds                          -                 [    8 x 1210]

Selectors -                                             [nCond x nTRs]
    1) runs                           -                 [    1 x 1210]
 2-11) runs_xval                      *   [GRP size 10] [    1 x 1210]

Masks -                                                 [ X  x  Y  x  Z ] [ nVox]
    1) VT_category-selective          -                 [ 64 x  64 x  40] [  577]
 2-11) epi_z_thresh0.05               *   [GRP size 10] [ 64 x  64 x  40] [  V  ]
* Variable-size groups truncated. See help for display info.
```

It's created a whole new ''epi\_z\_anova'' pattern group and ''epi\_z\_thresh0.05'' mask group based on that. The only problem with this is that we can't see how many voxels were allowed through on each iteration of the anova. To do that, try just showing the masks, including all the group members:

```
>> summarize(subj,'objtype','mask')

Subject 'tutorial_subj' in 'haxby8' experiment

Masks -                                                 [ X  x  Y  x  Z ] [ nVox]
    1) VT_category-selective          -                 [ 64 x  64 x  40] [  577]
    2) epi_z_thresh0.05_1             -   [GRP size 10] [ 64 x  64 x  40] [  577]
    3) epi_z_thresh0.05_2             -   [GRP size 10] [ 64 x  64 x  40] [  574]
    4) epi_z_thresh0.05_3             -   [GRP size 10] [ 64 x  64 x  40] [  573]
    5) epi_z_thresh0.05_4             -   [GRP size 10] [ 64 x  64 x  40] [  571]
    6) epi_z_thresh0.05_5             -   [GRP size 10] [ 64 x  64 x  40] [  575]
    7) epi_z_thresh0.05_6             -   [GRP size 10] [ 64 x  64 x  40] [  575]
    8) epi_z_thresh0.05_7             -   [GRP size 10] [ 64 x  64 x  40] [  573]
    9) epi_z_thresh0.05_8             -   [GRP size 10] [ 64 x  64 x  40] [  575]
   10) epi_z_thresh0.05_9             -   [GRP size 10] [ 64 x  64 x  40] [  573]
   11) epi_z_thresh0.05_10            -   [GRP size 10] [ 64 x  64 x  40] [  574]

```

The number on the right hand side of each row denotes how many voxels were allowed through (out of 577 in the original ''VT\_category-selective mask'') each time the ANOVA was run. In this tutorial data set, almost all of the voxels passed the ANOVA, because the ''VT\_category-selective mask'' was actually functionally defined with a GLM in AFNI to keep the number of voxels down. With other data sets, you'll find that an ANOVA-generated mask can be quite selective, when you start with a whole brain's worth of voxels.

We glossed over what actually happened inside feature\_select.m:

· First, it ran an ANOVA to generate the ''epi\_z\_anova, which contains p values for each voxel on each iteration.

· Then, ''create\_thresh\_mask'' was called (with the default value of 0.05 to create the boolean masks we have just been examining). We could have passed in a 'thresh' argument to ''feature\_select.m'' to have told ''create\_thresh\_mask'' to use a different threshold criterion. Or, we could call ''create\_thresh\_mask'' ourselves afterwards on the ''epi\_z\_anova'' multiple times to create lots of masks of differing stringency.

· Because both these steps ran multiple times (once for each iteration of the n-minus-one, leaving out a different run each time), both steps created groups. First a statmap pattern group (''epi\_z\_anova'') and then a boolean 3D volume mask group (''epi\_z\_thresh0.05'').

In fact, the ''feature\_select'' function is very powerful - you can easily feed in your own function to generate the statmaps instead of the default ANOVA if you prefer. This way, you can utilise the infrastructure to avoid peeking during feature selection with any feature selection method you like.''''

So, to summarize, the ''feature\_select.m'' ran ''statmap\_anova.m'' 10 times, each time using a different ''runs\_xval'' selector to use a different subset of the timepoints. This produced a group of 10 statmap patterns called ''epi\_z\_anova_#'', which were then thresholded to find voxels in them below a certain p value to create a group of 10 boolean masks called ''epi\_z\_thresh0.05_#''.


### Pre-classification summary ###

All the hard work has been done. Try nosing around the subj structure using the ''get\_object.m'' function to view the contents of the various objects that have been created.


### Cross-validation classification ###

Let's set some arguments for a basic backprop classifier with no hidden layer, and just leave the rest as the defaults:

```
>> class_args.train_funct_name = 'train_bp';

>> class_args.test_funct_name = 'test_bp';

>> class_args.nHidden = 0;
```

If you don't have the Matlab toolbox, you can use the Netlab open source toolbox instead. It seems to require a hidden layer, so try this instead of the above:

```
>> class_args.train_funct_name = 'train_bp_netlab';

>> class_args.test_funct_name = 'test_bp_netlab';

>> class_args.nHidden = 10;
```

Now, just call the ''cross\_validation.m'' function to classify our ''epi\_z'' data according to the ''conds'' conditions, which will call backprop multiple times, once per iteration of the n-minus-one, iterating through the ''runs\_xval'' selector and ''epi\_z\_thresh0.05'' mask groups each time.

```
>> [subj results] = cross_validation(subj,'epi_z','conds','runs_xval','epi_z_thresh0.05',class_args);

Starting 10 cross-validation classification iterations

1 0.44

2 0.55

3 0.42

4 0.52

5 0.41

6 0.45

7 0.46

8 0.40

9 0.43

10 0.48

Cross-validation using class_bp and got total_perfs - 0.4562 
```

Obviously, your performance values will be different because backprop randomly initializes its weights each time it is run.

Note: the ''cross\_validation.m'' and ''perfmet\_maxclass.m'' scripts have been updated now, and they check whether your training data contains rest. We have deliberately left the rest TRs in the tutorial\_easy dataset, and so you should see the following warning on each iteration:

```
Warning: Not 1-of-n regressors

>> In perfmet_maxclass>sanity_check at 91 

In perfmet_maxclass at 56

In cross_validation 211

In tutorial_easy at 77 
```

See the [Manual](Manual.md) / Howto's section for details on how to weed out these rest TRs from the analysis. We may remove this warning in future, since it's useful but often intrusive. Note that it is also possible to just turn it off - see the ''perfmet\_maxclass.m'' help.

### Results ###

Now, we're ready to examine the results that this has generated.

```
>> results

results =

header: [1x1 struct]

iterations: [1x10 struct]

total_perf: 0.4562 
```

The results.total\_perf tells us the overall proportion of the time that the classifier guessed correctly on its testing TRs (averaged across all 10 iterations).

Each ''iteration'' contains all the information needed to unpack what happened during classification during that iteration of the n-minus-one loop.

```
>> results.iterations(1)

ans =

perfmet: [1x1 struct]

perf: 0.4380

created: [1x1 struct]

train_idx: [1x1089 double]

test_idx: [1x121 double]

rest_idx: [1x0 double]

unknown_idx: [1x0 double]

acts: [8x121 double]

scratchpad: [1x1 struct]

header: [1x1 struct] 
```

The most important fields are the ''acts ''and ''perfmet'' fields. The ''acts'' matrix contains the activations for the 8 output units in the 121 test TRs for this iteration. These are the values that were used to determine this particular classifier's guesses, as stored in ''perfmet'' ('performance metric'):

```
>> results.iterations(1).perfmet

ans =

guesses: [1x121 double]

desireds: [1x121 double]

corrects: [1x121 logical]

perf: 0.4380

scratchpad: []

function_name: 'perfmet_maxclass' 
```

Have a look at ''guesses''. Each of the 121 values (one for each timepoint) ranges from 1-8, and indicates which condition the classifier thought that TR came from. The right answer is stored in ''desireds''. ''Corrects'' tells you whether the guess is the right answer, and ''perf'' tells you what proportion of the time you guessed right. The code for generating these is incredibly simple - see ''perfmet\_maxclass.m''.

Of course, you might want to calculate performance differently. You might want to give yourself a little pat on the back if you were almost right, whereas this only counts an answer as correct if the right unit was the most active. You might want to use a support vector machine instead of backprop. Three graduate students went insane calculating the combinatorics of all these possibilities. As a result, if you'd like to use a different classifier, or evalute its output with a different performance metric, this is easy to do. Just as with the statmap function, you can create your own, feed the name of the function in as an optional argument, and the cross-validation script will do all the n-minus-one no-peeking looping and build your results structure using your functions instead.

There is considerably more to say about classification and the results structure. See the 'Classification' section in the [Manual](Manual.md) for more information.


## Congratulations ##

Congratulations for completing this tutorial. Now you know
enough to be dangerous. Play with your data for a bit, and
then try TutorialAdv which builds on all these
concepts and introduces further procedures for the kinds of
things that you'll probably want to try before too long.

For instance, we aren't convolving our regressors with a
haemodynamic response function to take account of the lag in
the BOLD response - this is a pretty critical omission.


## Troubleshooting ##

This should work flawlessly, straight out of the box. No, really, it should.
If it doesn't, have a look at the [Troubleshooting](Troubleshooting.md) page. If absolutely none of that helps, [let us know](mailto:mvpa-toolbox@googlegroups.com).