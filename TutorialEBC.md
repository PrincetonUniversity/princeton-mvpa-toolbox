# EBC Tutorial #1 - Introduction (ebc\_tutorial\_intro.m) #

**Note: There have been significant changes to this tutorial since the initial 0.1 and 0.2 releases. Even if you already went through the tutorial once, it is highly recommended that you at least glance through it again now.**

This tutorial will guide you in a step-by-step fashion through some of the analysis necessary to recreate one of the Princeton EBC Team's submissions to the competition. This tutorial is geared for those who have never seen the MVPA toolbox before; if you already feel perfectly comfortable setting up and running an experiment in the toolbox from start to finish, you will want to skim through this and then start the advanced tutorial (ebc\_tutorial\_adv.m).

At this point, you should have the MVPA toolbox installed, along with the EBC extension, as well as the tutorial data in MATLAB form from the EBC website. For installation instructions, click here. Once you're ready to proceed, start up Matlab and (if you're using the GUI) load up ebc\_tutorial\_intro.m into the editor. (Don't worry if you don't have the GUI: you can enter the commands from this tutorial as we come to them, or you can copy from ebc\_tutorial\_intro.m as a reference.) Then head to the next section.








## Step 1 - Loading the data ##

### Data files ###

First, download the data by following the instructions on the [:ExpansionEBC:EBC Expansion Wiki page].

There should be four .mat files in the data archive that you downloaded:

  * tutorial\_ebc1.mat - subject 1's dataset
  * tutorial\_ebc2.mat - subject 2's dataset
  * tutorial\_ebc3.mat - subject 3's dataset
  * ebc\_params.mat - the optimal parameters for analysis

Each of the subject dataset files contains five matrices that we will use in our analysis. These are defined as follows:

  * epi - a matrix containing the fMRI voxel activations of some ~38,000 intra-cranial voxels. This matrix was created by the Princeton EBC team based on data downloaded from the EBC website. Rows of the matrix correspond to voxels, and columns correspond to TRs. To create this matrix, we imported the raw functional DICOM data into AFNI. The temporal offset of each slice within a volume was corrected using the 'tshift' option in AFNI's 3dvolreg script. This script was also used to motion correct by aligning all volumes from one subject to a single 'template' volume from that subject. Next, AFNI's 3dAutomask script was used to automatically create a brain mask so that only voxels with intensities likely to have come from inside the brain would be included in subsequent analysis. The data was then imported into Matlab using the Princeton MVPA toolbox and Ziad Saad's AFNI-Matlab library.
  * wholebrain - a binary, three-dimensional matrix that relates the epi matrix to the 3D fMRI voxel grid; when considered in sequential order, the n'th index with value 1 in wholebrain corresponds to the voxel in the n'th row of epi.
  * baseregs - a matrix containing the values of the subject-determined feature ratings for each TR. Rows of the matrix correspond to different features, and columns correspond to TRs.
  * condnames - a cell array holding the English names of the features in baseregs. For instance, codenames{1} is 'Amusement'.
  * movies - a row vector that records which phase of the experiment (movie #1 or movie #2) each TR corresponds to.
  * movies\_noblank - a binary matrix that indicates which TRs we consider 'rest' or 'blank', so that they may be excluded from our analysis. A value of 0 indicates a blank TR.

Let's assume you've extracted the data into the subdirectory data of your current working directory. The first step in our analysis is to load this data into RAM for the first subject.
```
>> load 'data/tutorial_ebc1';
>> whos
  Name                 Size                           Bytes  Class

  baseregs            30x1726                        414240  double array
  condnames            1x30                            3366  cell array
  epi              37828x1726                     522329024  double array
  movies               1x1726                         13808  double array
  movies_noblank       1x1726                         13808  double array
  wholebrain          64x64x34                      1114112  double array

Grand total is 65485897 elements using 523888358 bytes
```

There is another dataset that will find useful: ebc\_params.mat.  This contains a cell array of the optimized parameters obtained by the Princeton EBC Team from a parameter search. In our case, we will only need a small subset of these parameters, which we found provided the best performance.

Let's load these parameters now.

```
>> load 'ebc_params.mat'
>> default_params = ebc_params{1, 3, 2};
>> default_params

default_params =

                      N: [300 750 200 50 200 1500 400 100 100 200 1000 300 400]
                penalty: [0.0500 0 0 0.4500 0 0.0500 0 2 0.0500 0.2000 0 0.0500 0]
    time_average_window: [3 2 4 2 4 3 2 3 2 3 3 5 5]
                subject: 1
                fselect: 2
               noblanks: 1
```

Inside the ebc\_params.mat file, there is a cell array of default\_param objects called ebc\_params. Each index in the array corresponds to the result of one of our parameter searches: index {1, 3, 1} means that these are the parameters for subject 1, where spatial averaging was performed after feature selection, and where blanks were excluded from the training set. Don't worry too much about this now; all that matters is that we now have the optimal parameters for our experiment for each of the thirteen regressors of interest.

Next, we start loading the matrix data into the data structures used by MVPA, so we can take advantage of MVPA's automation.

### The MVPA Subject Structure ###

In the MVPA toolbox, all data relating to the analysis for a given subject in a given experiment is wrapped in a single object, idiomatically named subj. We initialize an empty subject with the experiment 'ebc';
```
>> subj = init_subj('ebc', 'subject1');
```
Next we insert the data we want into the subject structure, so that we can take advantage of the MVPA toolbox's automation. MVPA has four basic data types: pattern, regressors, selector, and mask.

### Masks ###

A mask object is used to specify which voxels in a particular pattern should be used for analysis. This allows us to easily select subsets of voxels for analysis based on whatever criteria we choose. Furthermore, since masks are 3D matrices, they also provide the grid locations of each voxel in the pattern they mask. The mask for our data is the matrix 'wholebrain' we loaded earlier.

To create a new mask object, we use the initset\_object function to INIT a new 'pattern' object named 'epi', and to SET the object with the matrix 'epi' we loaded already. Note that like almost all MVPA commands, the output is the modified subj structure, and the first input parameter is the subj structure on which to act.

```
>> subj = initset_object(subj, 'mask', 'wholebrain', wholebrain);
```

### Patterns ###

A pattern object is used to hold any dataset that we will use as the basis of our analysis. Typically these are voxel timeseries, but they can also be statistics of interest or some transformed or dimensionality reduced form of the original data, as well. In any case, now that we have our mask, we load the voxel pattern that we will be analyzing, and and associate it with the mask. We can use the same initset\_object function as before, but we pass in an optional object field, masked\_by, that specifies the mask associated with a given pattern.

```
>> subj = initset_object(subj, 'pattern', 'epi', epi, 'masked_by', 'wholebrain');
```

### Regressors ###

A regressors object is used to store any set of data that is a label for the training or testing phases of the experiment, i.e. a variable that is trying to be predicted. (Yes, the name can be confusing -- technically, in the prediction experiment, the voxels are the regressors -- but it is the best we have for now.) The baseregs and condnames data are inserted into subj as a new regressors object, where condnames is an optional object field like masked\_by was. First we take only the first thirteen regressors (these are the only ones of interest), and then we create our new object:

```
>> baseregs = baseregs(1:13, :);
>> condnames = condnames(1:13);
>> subj = initset_object(subj, 'regressors', 'baseregs', baseregs, 'condnames', condnames);
```

### Selectors ###

Finally, a selector object is used to label each timepoint with information about the experiment: integers represent different runs of the fMRI scanner, or a binary selector indicates rest TRs to be excluded from analysis. MVPA will automatically set up an N-1 cross-validation experiment (isolate one run for test data, and assess performance by training on the rest, rotated across all runs) for you later on using these selectors. Thus the movies and movies\_noblank vectors are inserted as selector objects.

```
>> subj = initset_object(subj, 'selector', 'movies', movies);
>> subj = initset_object(subj, 'selector', 'movies_noblank', movies_noblank);
```

We now have our completed subject structure. We use the command summarize to print out the information on what we have just created.

```
>> summarize(subj)

Subject 'subject1' in 'ebc' experiment

Patterns -                                              [ nVox x nTRs]
    1) epi                            -                 [37828 x 1726]

Regressors -                                            [nCond x nTRs]
    1) baseregs                       -                 [   13 x 1726]

Selectors -                                             [nCond x nTRs]
    1) movies                         -                 [    1 x 1726]
    2) movies_noblank                 -                 [    1 x 1726]

Masks -                                                 [ X  x  Y  x  Z ] [ nVox]
    1) wholebrain                     -                 [ 64 x  64 x  34] [37828]
```

Lastly, we clean up the unneeded raw data we loaded just before:

```
>> clear epi baseregs movies movies_noblank condnames wholebrain;
```

## Step 2 - Pre-processing the data: z-scores and more ##

### De-trending ###

Although many times removing linear trends from the data can be done in other programs (such as AFNI), our data has not yet been processed in this way. Thus the first step is to run Matlab's detrend function on the data. However, it's important that we detrend each run separately; while doing such a simple operation might be relatively easy (maybe 5-10 lines of Matlab code) to code right on the spot, MVPA makes it easy for us to apply any arbitrary function to specific runs of a pattern. We use the `apply_to_runs` function to do this using the following command.

```
>> subj = apply_to_runs(subj, 'epi', 'movies', 'apply_detrend');
Beginning apply_to_runs, function 'apply_detrend': # runs = 2
        1       2
Pattern epi_detrend created by apply_to_runs
```

apply\_to\_runs takes in four mandatory arguments: the subj structure, the pattern object to be processed, the selector object designating runs, and then the name of the function to be called on each run. Then apply\_to\_runs creates a new pattern for us that contains the individually processed runs concatenated back together.

The only requirement for a function to be applied to runs is that it must take as input the pattern associated with a single run and return some processed form of that run. More arguments can be passed in optionally (again, more on this later.) We have already implemented for you three useful functions: apply\_detrend, apply\_zscore, and apply\_filt, which detrend, z-score, and filter the data respectively. We're planning on adding denoising techniques (such as shrinkage on discrete wavelet transform coefficients) in the future, but feel free to make your own apply_functions for any preprocessing you might wish to perform on the data. (We'd like to see them, too!)_

Finally, now that we have our new pattern 'epi\_detrend', we won't need the original pattern epi anymore. To conserve RAM (each full 38000x1726 pattern takes up about 500MB of memory), we tell MVPA to move the pattern epi from RAM to the harddrive, where it is automatically saved to a folder and managed. This is accomplished via the move\_pattern\_to\_hd function.

```
>> subj = move_pattern_to_hd(subj, 'epi');
>> summarize(subj);

Subject 'subject1' in 'ebc' experiment

Patterns -                                              [ nVox x nTRs]
    1) epi                            -                 [37828 x 1726] [HD]
    2) epi_detrend                    -                 [37828 x 1726]

Regressors -                                            [nCond x nTRs]
    1) baseregs                       -                 [   13 x 1726]

Selectors -                                             [nCond x nTRs]
    1) movies                         -                 [    1 x 1726]
    2) movies_noblank                 -                 [    1 x 1726]

Masks -                                                 [ X  x  Y  x  Z ] [ nVox]
    1) wholebrain                     -                 [ 64 x  64 x  34] [37828]
```

Summarizing, we see that pattern epi now has the notation [HD](HD.md) next to it: this indicates that the pattern is currently stored on the hard drive.

### Z-Scoring ###

Now that we have de-trended, Z-Scoring the data (divide by standard deviation, subtract the mean) is an essential step of the analysis. This is again an operation we want performed on an individual run basis; we again will use the apply\_to\_runs, but this time we specify apply\_zscore instead. Additionally, we want to specify a name for the new pattern this time: instead of creating a new pattern called 'epi\_detrend\_zscore', we will have apply\_to\_runs create a new pattern simply named epi\_z for simplicity.

To pass in optional parameters to any MVPA function, we typically use property-value pairs: first a string naming the optional variable we are providing, and then the value that we wish to assign to that variable. We demonstrate this in the next code sample.

```
>> subj = apply_to_runs(subj, 'epi_detrend', 'movies', 'apply_zscore', 'new_patname', 'epi_z');
Beginning apply_to_runs, function 'apply_zscore': # runs = 2
        1       2
Pattern epi_z created by apply_to_runs
```

Once again, we now have another pattern residing in memory that we're not going to use. We'll move it back to the hard drive, like we did before:

```
>> subj = move_pattern_to_hd(subj, 'epi_detrend');
```

### Avoiding 'peeking' ###

Another crucial pre-processing step is to remove uninformative voxels from the analysis. This involves choosing and calculating a test statistic for our pattern, and then either removing all voxels beneath a certain threshold (say, p<0.05 from an ANOVA) or taking some sorted subset of the voxels (say, the lowest 500 p-values). But before we do any feature selection, we want to ensure that we avoid 'peeking' at all times: if any data point is going to be used in the testing phase of our cross validation experiment, we cannot include it in our statistical calculations when selecting important voxels. This would artifically boost the performance of our training and could lead us to conclude that we have better generalization performance than is actually the case. Thus, even though we are not ready to perform the experiment, we need to set up the data partitioning of the cross validation experiment in order to rigorously complete our pre-processing.

Luckily, this is quite easy within the MVPA toolbox. The create\_xval\_indices function will automatically partition a single selector object intoa group of leave-out-one cross-validation trials. Furthermore, if we specifiy an actives selector, a binary selector indicating blank or rest TRs, create\_xval\_indices will also remove these rest TRs from our experimental trials too. Thus setting up the cross validation selectors is reduced to a single command.

```
>> subj = create_xvalid_indices(subj, 'movies', 'actives_selname','movies_noblank');
Selector group 'movies_xval' created by create_xvalid_indices

>> summarize(subj)

Subject 'subject1' in 'ebc' experiment

Patterns -                                              [ nVox x nTRs]
    1) epi                            -                 [37828 x 1726] [HD]
    2) epi_detrend                    -                 [37828 x 1726] [HD]
    3) epi_z                          -                 [37828 x 1726]

Regressors -                                            [nCond x nTRs]
    1) baseregs                       -                 [   13 x 1726]

Selectors -                                             [nCond x nTRs]
    1) movies                         -                 [    1 x 1726]
    2) movies_noblank                 -                 [    1 x 1726]
    3) movies_xval_1                  -   [GRP size  2] [    1 x 1726]
    4) movies_xval_2                  -   [GRP size  2] [    1 x 1726]

Masks -                                                 [ X  x  Y  x  Z ] [ nVox]
    1) wholebrain                     -                 [ 64 x  64 x  34] [37828]
```

We now have two new selector objects corresponding to the two iterations of our cross-validation experiment: movies\_xval\_1 and movies\_xval\_2. These are both part of a group named movies\_xval.

### Voxel selection using cross correlation ###

Now we are ready to extract the important voxels from the data. We will select a subset of the most informative voxels from the 38,000 in 'epi\_z'. In the MVPA toolbox, this is implemented as the feature\_select function: feature\_select takes in pattern, regressors, and selector objects and optionally creates a new mask selecting voxels that match some desirability metric: since MVPA was originally designed to facilitate classification experiments (predicting discrete conditions), the default is to select voxels that vary significantly across conditions using an ANOVA with a threshold of p<0.05.

However, we are performing regression, not classification, and our regressors are continuous variables and not discrete labels; we cannot perform an ANOVA, so we instead use the cross-correlation coefficient between each voxel and each feature regressor. These values will be stored in a type of pattern object called a statmap: a single value for each voxel that corresponds to some statistic that is useful in the future. To perform feature selection, we will calculate the cross-correlation coeffficients for each voxel and each regressor variable, store these in a statmap pattern, and then finally create a new mask object to select only the highest N voxels from that statmap, where N is a parameter we take from the default\_params structure. We will use these masks when we run our learning and prediction algorithms. (Note: MVPA allows you to easily create and plug in your own statmap functions for use in feature\_select.)

Because this is an introductory tutorial, we will limit our analysis to a single regressor of interest. However, so that we can consider each regressor separately, we use MVPA's separate\_regressors function to break a regressors matrix into a group of individually named row vectors.

```
>> subj = separate_regressors(subj, 'baseregs');
Regressors group 'baseregs_grp' created by separate_regressors.m

>> summarize(subj)

Subject 'subject1' in 'ebc' experiment

Patterns -                                              [ nVox x nTRs]
    1) epi                            -                 [37828 x 1726] [HD]
    2) epi_detrend                    -                 [37828 x 1726] [HD]
    3) epi_z                          -                 [37828 x 1726]

Regressors -                                            [nCond x nTRs]
    1) baseregs                       -                 [   13 x 1726]
    2) Amusement                      -   [GRP size 13] [    1 x 1726]
    3) Attention                      -   [GRP size 13] [    1 x 1726]
    4) Arousal                        -   [GRP size 13] [    1 x 1726]
    5) Body Parts                     -   [GRP size 13] [    1 x 1726]
    6) Environmental Sounds           -   [GRP size 13] [    1 x 1726]
    7) Faces                          -   [GRP size 13] [    1 x 1726]
    8) Food                           -   [GRP size 13] [    1 x 1726]
    9) Language                       -   [GRP size 13] [    1 x 1726]
   10) Laughter                       -   [GRP size 13] [    1 x 1726]
   11) Motion                         -   [GRP size 13] [    1 x 1726]
   12) Music                          -   [GRP size 13] [    1 x 1726]
   13) Sadness                        -   [GRP size 13] [    1 x 1726]
   14) Tools                          -   [GRP size 13] [    1 x 1726]

Selectors -                                             [nCond x nTRs]
    1) movies                         -                 [    1 x 1726]
    2) movies_noblank                 -                 [    1 x 1726]
    3) movies_xval_1                  -   [GRP size  2] [    1 x 1726]
    4) movies_xval_2                  -   [GRP size  2] [    1 x 1726]

Masks -                                                 [ X  x  Y  x  Z ] [ nVox]
    1) wholebrain                     -                 [ 64 x  64 x  34] [37828]
```

We now have thirteen new regressors objects corresponding to the individual rows of our baseregs matrix. We only need one of them, but it's okay to leave the rest in, because none of these objects takes up close to the amount of RAM that our single epi\_z pattern does. Furthermore, if you find that the output from summarize is getting too crowded, you can always turn off the display of individual group members:

```
>> summarize(subj, 'display_groups', false);

Subject 'subject1' in 'ebc' experiment

Patterns -                                              [ nVox x nTRs]
    1) epi                            -                 [37828 x 1726] [HD]
    2) epi_detrend                    -                 [37828 x 1726] [HD]
    3) epi_z                          -                 [37828 x 1726]

Regressors -                                            [nCond x nTRs]
    1) baseregs                       -                 [   13 x 1726]
 2-14) baseregs_grp                   *   [GRP size 13] [    1 x 1726]

Selectors -                                             [nCond x nTRs]
    1) movies                         -                 [    1 x 1726]
    2) movies_noblank                 -                 [    1 x 1726]
 3- 4) movies_xval                    *   [GRP size  2] [    1 x 1726]

Masks -                                                 [ X  x  Y  x  Z ] [ nVox]
    1) wholebrain                     -                 [ 64 x  64 x  34] [37828]
```

Now it's time to run feature\_select. In this example, we're choosing the 'Amusement' regressor, but you can use whichever you want in your own experiments. Because feature\_select was originally designed for classification, we need to pass in a bunch of optional arguments to specify that we want to use our own statmap function and to avoid automatically creating a threshold mask. Thus, the optional arguments statmap\_funct and statmap\_arg become statmap\_xcorr (our cross-correlation statistic, written in statmap\_xcorr.m) and [.md](.md) (it needs no extra arguments.) Furthermore, we set the thresh argument to [.md](.md)(empty) to prevent feature\_select from automatically creating threshold masks for us.

```
>> subj = feature_select(subj, 'epi_z', 'Amusement', 'movies_xval', 
                         'statmap_funct', 'statmap_xcorr', 
                         'statmap_arg', [],
                         'new_map_patname', 'stat_Amusement', 
                         'thresh', []);
Starting 2 statmap_xcorr iterations
        1       2
Pattern statmap group 'stat_Amusement' and mask group 'epi_z_thresh' created by feature_select

>> summarize(subj)

Subject 'subject1' in 'ebc' experiment

Patterns -                                              [ nVox x nTRs]
    1) epi                            -                 [37828 x 1726] [HD]
    2) epi_detrend                    -                 [37828 x 1726] [HD]
    3) epi_z                          -                 [37828 x 1726]    
    4) stat_Amusement_1               -   [GRP size  2] [37828 x    1]
    5) stat_Amusement_2               -   [GRP size  2] [37828 x    1]

Regressors -                                            [nCond x nTRs]
    1) baseregs                       -                 [   13 x 1726]
    2) Amusement                      -   [GRP size 13] [    1 x 1726]
    3) Attention                      -   [GRP size 13] [    1 x 1726]
    4) Amusement                      -   [GRP size 13] [    1 x 1726]
    5) Body Parts                     -   [GRP size 13] [    1 x 1726]
    6) Environmental Sounds           -   [GRP size 13] [    1 x 1726]
    7) Faces                          -   [GRP size 13] [    1 x 1726]
    8) Food                           -   [GRP size 13] [    1 x 1726]
    9) Language                       -   [GRP size 13] [    1 x 1726]
   10) Laughter                       -   [GRP size 13] [    1 x 1726]
   11) Motion                         -   [GRP size 13] [    1 x 1726]
   12) Music                          -   [GRP size 13] [    1 x 1726]
   13) Sadness                        -   [GRP size 13] [    1 x 1726]
   14) Tools                          -   [GRP size 13] [    1 x 1726]

Selectors -                                             [nCond x nTRs]
    1) movies                         -                 [    1 x 1726]
    2) movies_noblank                 -                 [    1 x 1726]
    3) movies_xval_1                  -   [GRP size  2] [    1 x 1726]
    4) movies_xval_2                  -   [GRP size  2] [    1 x 1726]

Masks -                                                 [ X  x  Y  x  Z ] [ nVox]
    1) wholebrain                     -                 [ 64 x  64 x  34] [37828]
```

Ignore the 'epi\_z\_thresh' message output; there was no mask created, and that message is a minor bug that will be fixed in the next release. We now have have a group of two statmap patterns for our 'Amusement' regressor, one for each iteration of the cross validation experiment (remember, we need to avoid 'peeking.') We next create a group of mask objects named 'Amusement' and containig the N ``best_voxels using the created\_sorted\_mask function. In the case of_Amusement_, N equals 400._

```
>> subj = create_sorted_mask(subj, 'stat_Amusement', 'Amusement', 400);
>> summarize(subj, 'display_groups', false)

Subject 'subject1' in 'ebc' experiment

Patterns -                                              [ nVox x nTRs]
    1) epi                            -                 [37828 x 1726] [HD]
    2) epi_detrend                    -                 [37828 x 1726] [HD]
    3) epi_z                          -                 [37828 x 1726]
 4- 5) stat_Amusement                 *   [GRP size  2] [37828 x    1]

Regressors -                                            [nCond x nTRs]
    1) baseregs                       -                 [   13 x 1726]
 2-14) baseregs_grp                   *   [GRP size 13] [    1 x 1726]

Selectors -                                             [nCond x nTRs]
    1) movies                         -                 [    1 x 1726]
    2) movies_noblank                 -                 [    1 x 1726]
 3- 4) movies_xval                    *   [GRP size  2] [    1 x 1726]

Masks -                                                 [ X  x  Y  x  Z ] [ nVox]
    1) wholebrain                     -                 [ 64 x  64 x  34] [37828]
 2- 3) Amusement                      *   [GRP size  2] [ 64 x  64 x  34] [  350]
```

Now we have two new mask objects, again, one for each iteration of the cross validation experiment. At this point we will begin the optimizations used by Denis Chirigev and Greg Stephens in their prize-winning EBC submission.

## Step 3 Optimization through averaging ##

There are two major optimizations we can perform at this point. The first is to spatially average values of the intra-cranial voxels. Note that we are performing this spatial smoothing after already selecting for the most important voxels based on non-smoothed data. This is because it seems to provide the best performance empirically, and this is the way that Denis & Greg implemented their smoothing when they were under time pressure. Once you've finished the tutorials, you should be able to try experimenting with various smoothing configurations to see if you can improve performance even more.

To perform the spatial filtering, we use the function create\_spatial\_avg\_pat, which takes in a pattern name and a mask name and spatially smooths the voxels that survive the mask (thus eliminating the need to smooth extra-cranial voxels or the need to pad borders with zeros.) This is very computational expensive to write within Matlab, and is currently the longest operation of this toolbox. Depending on the speed of your processor, this should take somewhere between 10 and 45 minutes to complete. Note that once again, once the operation is complete, we will move the old pattern out of memory to conserve RAM.

```
>> subj = create_spatial_avg_pat(subj, 'epi_z', 'wholebrain');
Starting create_spatial_avg_pat on 'epi_z', 37828 voxels
        progress: 0.10 0.20 0.30 0.40 0.50 0.60 0.70 0.80 0.90
Pattern 'epi_z_savg' created by create_spatial_avg_pat

>> subj = move_pattern_to_hd(subj, 'epi_z');
```

Another important optimization is to temporally average individual voxels. This generally boosts generalization performance by at least 0.1 in the correlation coefficient. At this point, we're going to temporally filter the spatially smoothed pattern generated by the previous step, 'epi\_z\_savg'. However, this time, we can save on memory and computation time by only smoothing those voxels that we know we will be using in the regression at the end of this experiment; we will use the two masks in the mask group Amusement (generated from the statmap stat\_Amusement) and filter only voxels that are allowed through the mask. We also want to filter each run separately as well.

Once again we can use apply\_to\_runs: as optional parameters, apply\_to\_runs will take in a mask name or the name of a mask group, and for each mask in th group, it will apply the processing to individual runs of a masked pattern. Thus, running apply\_to\_runs with the mask group Amusement will produce two new filtered patterns. Finally, we need to create the filter based on the default parameters we loaded before. We see that the default time\_average\_window parameter is 3.

The first step to begin filtering is to make the averaging box filter the data will be filtered by. This is just a row vector of the desired size that sums to one.

```
>> filt = ones(1, 3);
>> filt = filt./sum(filt);
```

Now we pass this filter into apply\_filt through apply\_to\_runs as an optional argument, 'filt'. All the optional arguments to apply\_filt are passed to the interior 'apply' function as well. Furthermore, we specify that this pattern group should be named _epi\_z\_savg\_tavg\_Amusement_, so that it is clear how the pattern was created: spatial and temporal averaging, with the Amusement mask.

```
>> subj = apply_to_runs(subj, 'epi_z_savg', 'movies', 'apply_filt', 
                        'maskname', 'Amusement', 'new_patname',
                        'epi_z_savg_tavg_Amusement',
                        'filt', filt);
Beginning apply_to_runs, function 'apply_filt': # runs = 2
        1       2
Pattern group epi_z_savg_tavg_Amusement created by apply_to_runs
```

If we now summarize, we see the new epi\_z\_savg\_tavg\_Amusement group of patterns, just as we wanted. We're now finished all pre-processing of the data, and can continue on to the cross validation stage of the experiment.

```
>> summarize(subj, 'display_groups', false)

Subject 'subject1' in 'ebc' experiment

Patterns -                                              [ nVox x nTRs]

    1) epi                            -                 [37828 x 1726] [HD]
    2) epi_detrend                    -                 [37828 x 1726] [HD]
    3) epi_z                          -                 [37828 x 1726] [HD]
 4- 5) stat_Amusement                 *   [GRP size  2] [37828 x    1]
    6) epi_z_savg                     -                 [37828 x 1726]
 7- 8) epi_z_savg_tavg_Amusement      *   [GRP size  2] [  400 x 1726]

Regressors -                                            [nCond x nTRs]
    1) baseregs                       -                 [   13 x 1726]
 2-14) baseregs_grp                   *   [GRP size 13] [    1 x 1726]

Selectors -                                             [nCond x nTRs]
    1) movies                         -                 [    1 x 1726]
    2) movies_noblank                 -                 [    1 x 1726]
 3- 4) movies_xval                    *   [GRP size  2] [    1 x 1726]

Masks -                                                 [ X  x  Y  x  Z ] [ nVox]
    1) wholebrain                     -                 [ 64 x  64 x  34] [37828]
 2- 3) Amusement                      *   [GRP size  2] [ 64 x  64 x  34] [  350]
```

## Step 4 - Regression/Prediction: n-minus-one cross validation ##

At this point performing the actual cross validation experiment and getting our predictions is very easy. The cross\_validation function will perform an entire cross validation experiment for a given pattern or group of pattern, given a set of regressors, selector objects, and mask objects. By default, the MVPA toolbox is configured for classification experiments, which calculate performance by tallying 'errors' made when the prediction of the algorithm doesn't match the label in the regressors object. Thus, we will need to use our own performance metric function if we want to calculate the correlation coefficient of the predictions with the real regressor values. This custom metric is already written in perfmet\_xcorr.m (Note: MVPA makes it easy to write your own performance metrics and plug them into cross\_validation; see the manual for details.)

In this tutorial, we'll be using the ridge regression algorithm as implemented by Greg Stephens. This is set using the class\_args structure, which is required by cross\_validation and which is passed to the specified training and testing algorithms. As a penalty parameter, we choose the value taken from default\_params, which in this case is 0.05, multiplied by the number of voxels included int the analysis (400). A good rule of thumb for ridge regression is that the penalty parameter should increase linearly as the number of voxels included increases. We will also substitute some variables for values that one might normally hard-code, so that the syntax of cross\_validation will be more clear to the reader.

```
>> class_args.train_funct_name = 'train_ridge';
>> class_args.test_funct_name = 'test_ridge';
>> class_args.penalty = 0.05 * 400;
>> regsname = 'Amusement';
>> maskname = 'Amusement';
```

Finally, like feature\_select, we want to override many of the default classification-based settings of cross\_validation: we specify perfmet\_functs to be perfmet\_xcorr (we're using cross correlation, which takes no arguments.) All iterations of the experiment will be run automatically, and all relevant data to the experiment will be recorded in a results structure that is returned by cross\_validation. (We're not going to go into the details results structure here, but feel free to explore it on your own.)

```
>> [subj results] = cross_validation(subj, 'epi_z_savg_tavg_Amusement', regsname, 'movies_xval', maskname, class_args, 
                                 'perfmet_functs', 'perfmet_xcorr');
Starting 2 cross-validation classification iterations - train_ridge
        1       0.11
        2       0.36

060623_1457: Cross-validation using train_ridge and test_ridge - got total_perfs - 0.23561
>> results

results =

        header: [1x1 struct]
    iterations: [1x2 struct]
    total_perf: 0.2356
```

Although the cumulative score across both iterations is only 0.2356, and the score on the first iteration is still dismal, the score of .36 on the second iteration (generalizing from movie 1 onto movie 2) is indicative of the advantages to this approach. In the advanted tutorial, several more steps towards optimization are taken: leaving blanks in the training runs, using slightly different parameters, and averaging the predictions of all three subjects together. When these optimizations are all performed, the final EBC (transformed) score is .476, much higher than one might anticipate.

## Conclusion ##

This concludes the introductory tutorial. If you're confused and need more detailed explanations about any particular part of the toolbox, please see the appropriate section in the manual. If you want to continue the analysis and get results for each regression and every subject, please continue to the advanced tutorial by loading and examining ebc\_tutorial\_adv.m Right now, there is no HTML writeup for the advanced tutorial, but the code is quite similar (just with more loops and Matlab tricks) and there should be comments to help you along the way.

Thank you for downloading the MVPA toolbox, and we hope that you will find it useful.