# Visualizing your data in various ways #




---


The toolbox provides a growing number of ways to plot and visualize your data, for diagnosing problems, looking for artifacts and getting a sense of how the patterns and conditions relate to one another.

## Visualizing Brainmaps ##

There are two ways to visualize a brain map: 1) writing out to AFNI or another format and visualizing it using an external tool, and 2) visualizing it using the toolbox. There are pros and cons of each: in AFNI, it's very easy to do things like cluster and jump between clusters, but it's harder to do things like specify complex masks, rapidly try out different MVPA computations, get precise color maps, and so forth. In Matlab, it's possible to work much more rapidly, but you lose some of the advanced neuroscientific features of AFNI. However, we have recently dramatically improved the capabilities of our Matlab brain map visualization tools, such that for the purposes of most users, writing to AFNI is not necessary just to investigate a set of results (for instance, looking at statmaps in a single subject).

In this tutorial, we're going to go over how to use the Matlab visualization tools provided in the MVPA toolbox. There are actually two sets of tools: the MR\_MONTAGE library that has been included in the toolbox for a long time, provided by Keith Schneider, and a brand-new (as of the last release) set of MVPA specific tools, called VIEW\_PATTERN\_OVERLAY, and provided by David Weiss. To learn how to do export to AFNI, see the dicussion in TutorialAdv on exporting using WRITE\_TO\_AFNI.m.

Note: a Wiki-formatted tutorial on VIEW\_PATTERN\_OVERLAY is not available yet. However, there is a set of detailed examples and instructions in the file VIEW\_PATTERN\_OVERLAY.M accessible via the "help" command, that should provide you with everything you need to get started.

### Using anatomical data as an underlay ###

Although it's possible to make montages and view patterns with just whatever data you happen to have in your subj structure, it's a lot more informative and prettier if you have some structural data to serve as an underlay for your maps (otherwise you'll just get a gray slate).

Firstly, you'll need to import the intra-cranial BRIK created by 3dAutomask as a mask (this should be included with the sample data).

```
>> subj = load_afni_mask(subj,'wholebrain','wholebrain+orig');
```

The second step requires us to run some AFNI commands to downsample the resolution of the anatomical. Otherwise we won't be able to fit it into the mask we just loaded.

We have to downsample the anatomical because the toolbox doesn't incorporate any sophisticated tools for coregistering the high-res anatomical to the low-res functional. So the simplest thing to do is to bring the resolution of the anatomical down to the level of the functional. In the shell:

```
$ 3dresample \
  -master haxby8_r1+orig \
  -prefix structural_down \
  -inset structural+orig
```

You should now be the proud owner of a shiny new low-res anatomical called 'structural\_down+orig.BRIK'.

Now, we need to import this into the toolbox as a pattern (since we want to preserve its non-binary values):
```
>> subj = load_afni_pattern(subj,'anat','wholebrain','structural_down+orig', ...
                         'sub_briks',1);
```
We don't actually need to specify to just load the first sub-brik of the structural, which for some reason has two sub-briks, as `view_pattern_overlay` can choose which sample of the underlay to plot, but it just makes things a lot simpler if we do so now.

**Note:** in previous versions of the tutorial, we told you to create a 'wholevol' mask consisting entirely of ones, and load the pattern that way. It's a lot more memory efficient to just load the anatomical data into the mask of the brain, rather than the entire cube, but if you really want to see the skull and head anatomy, you can do this.

Ideally you'd not be using the raw structural at all, but rather a skull-stripped image that's been aligned to your mean EPI image, but that's a tutorial for another day.


### VIEW\_MONTAGE ###

Finally, we're ready to visualize the intra-cranial mask on top of the low-res anatomical.

```
view_montage(subj,'pattern','anat','mask','wholebrain')
```

If you were unable to create the low-res anatomical, fear not - your time has come. If we want to look at which bits are being picked out by the 577-voxel ventral temporal-plus-GLM mask that we've used for convenience so far:

```
view_montage(subj,'mask','wholebrain','mask','VT_category-selective')
```

VIEW\_MONTAGE.M is somewhat flexible, in that both the underlay and the overlay can be either a pattern or a mask. Here, we're overlaying a mask on a mask. Before, we were overlaying a mask on an anatomical pattern.

You could just as easily view the results of running some kind of feature selection as a brain map. For instance, if you'd just run TutorialEasy, then you could view the p-values from running the ANOVA (for the first iteration):

```
view_montage(subj,'mask','wholebrain','mask','epi_z_anova');
```

or if you wanted to just see the voxels that passed your threshold:

```
view_montage(subj,'mask','wholebrain','mask','epi_z_thresh0.05_1');
```

N.B. As already discussed in TutorialEasy, the ANOVA feature selection as described doesn't really throw away any of the 577 voxels from the VT mask, and so this isn't very illuminating.

VIEW\_MONTAGE also offers a few options for restricting which slices to look at, doing some simple thresholding etc. It cannot show the data over time, from different views etc.

## More sophisticated brainmaps with VIEW\_PATTERN\_OVERLAY ##

In version 1.0 of the toolbox, we incorporated a new brainmaps visualization tool called VIEW\_PATTERN\_OVERLAY. This is a more sophisticated and interactive tool than VIEW\_MONTAGE. We haven't written a tutorial for it yet, but once you've got the hang of VIEW\_MONTAGE, then the help within VIEW\_PATTERN\_OVERLAY is pretty extensive and contains many examples.


## Diagnosing signal artifacts ##

Specialized neuroimaging software such as AFNI and SPM offer various diagnostic and remedial tools for noticing outlier timepoints, smoothing away spikes, getting rid of linear and quadratic trends etc. The tools in the MVPA toolbox are pretty limited in comparison.

If you want to look at how the global signal (the mean of all the voxels) changes over time:

```
plot_stability(subj,'epi','runs')
```

This is most useful if you'd like to see how some preprocessing step affects this global signal, since you can overlay the before and after timecourses with the PROC\_PATNAME argument. It's useful for noticing large spikes or unnaturally high variability, as well as scanner drift within runs and baseline shift across runs. For instance, we can see the effect of z-scoring each voxel's timecourse within runs:

```
>> plot_stability(subj,'epi','runs', 'proc_patname','epi_z')
```

Blue = raw data. Green = z-scored.

## Looking at the motion parameters ##
Unfortunately, we aren't able to provide AFNI motion parameters for the sample dataset. But if we could:

```
>> plot_motion(subj,'conds','runs','mc_params.txt')
```

This might help us see whether any of the runs have particularly serious motion problems, or whether some of the conditions have more motion than others (e.g. this can be a problem with free recall studies).

## Seeing your data in low-dimensional space ##
Multi-dimensional scaling is a well-known technique for dimensionality reduction. Dimensionality reduction deserves its own full tutorial, but we'll just touch on how you can use MDS as a means of visualizing your functional data in low-dimensional space using PLOT\_MDS.M.

PLOT\_MDS.M computes a matrix of distances between every single pair of timepoints, i.e. it compares every brainstate in your functional data with every other brainstate. It then tries to find a projection from high-dimensional (one dimension per voxel) into low-dimensional space, that best preserves these pairwise distances. Intuitively then, every single timepoint in your dataset is going to end up a point on the screen, such that similar timepoints will be plotted close to one another (ideally). The algorithm is completely unsupervised, i.e. it ignores your condition labels. After it has run, we color each point according to its condition, and plot the centroids of each condition's cloud of points. We would like to see the clouds for each condition as tightly clustered and cleanly separated from one another as possible. We might also hope to see that the points for similar conditions will be more similar to one another than the points for dissimilar conditions.

```
plot_mds(subj,'epi_z','conds')
```

Because the default is to project down to three dimensions, you can use the Rotate tool to rotate the axes of the figure. It's a little hard to know what to say about this figure, except that there does seem to be a good degree of clustering and separation of conditions. For instance, the red 'chair' points seem to lie on the opposite side of the space from the blue 'faces' points. Of course, we are only feeding in voxels that passed a GLM, and that we know discriminate between the conditions, and so we shouldn't be too surprised that this separation is evident in this low-dimensional projection. Still, it is gratifying.

The second 'eigenvalues' plot shows how well the MDS was able to account for the variance in the data. Like a PCA, the dimensions are ranked. This plot shows how much of the 577-dimensional space's variance could be captured by the 3 dimensions.

## Deviations from condition mean for each timepoint ##
The PLOT\_DEVIATIONS\_FROM\_CONDMEAN.M function finds all the timepoints for a given condition, and collapses them together to get a condition-mean brainstate (one per condition). It then goes through each timepoint, and computes how similar that timepoint is to each of the condition-means. That's what the 'deviations fo each timepoint from its condition mean' plot is showing. The top row of the complicated 3 x 10 plot shows these timepoint-by-timepoint deviations from each of the condmeans in a different form. A dark square signifies that that timepoint is similar to that condition mean. Obviously, we would like each timepoint to be similar to the correct condition-mean, and dissimilar from all the others. The middle row shows us which condition is active (so that we can easily compare with the dark/light squares above), and the bottom row simply reports whether that timepoint is 'correct', i.e. most similar to the appropriate condition mean.

```
plot_deviations_from_condmean(subj,'epi','conds','runs')
```

If you like, you could think of this as a very simple form of classification - a 1-nearest neighbor classifier with a Euclidean distance metric. This can sometimes help you debug more complicated classification analyses - if this is working at all, then you should expect a sophisticated learning algorithm like backprop to do even better...