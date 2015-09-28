# Tutorial on spherical searchlights #





[Kriegeskorte, Goebel & Bandettini (2006)](http://www.pnas.org/cgi/content/abstract/0600244103v1) propose a method that combines many of the virtues of both univariate and multivariate techniques. In short, they define a local spherical mask, centered in turn on every one of the voxels inside the brain, and perform a multivariate test on each of those spherical regions. This "information-based mapping" approach preserves information that might be present in the fine spatial patterns, while also imposing a locality constraint (by only looking at voxels within a circumscribed region).

The MVPA toolbox provides a flexible framework for running analyses of this kind, creating the spherical (or other-shaped) searchlights, ready for you to drop in your multivariate test/algorithm of choice on each sphere, and automatically assigns the results of each test to the voxel at the center. You can then threshold this statmap to create a mask, just as you do with any other statmap. It utilizes the same FEATURE\_SELECT.M function as simpler, univariate approaches (such as the default STATMAP\_ANOVA.M), and so you can easily run this within an n-1 leave-one-out cross-validation analysis design.

For the purposes of this tutorial, we're going to run a [Gaussian Naive Bayes](http://www.cs.cmu.edu/~tom/mlbook/NBayesLogReg.pdf) (GNB) classifier as the 'multivariate statistical test' for each sphere. In other words, we're going to go through each voxel in the brain, grab all the voxels within a predefined radius of that center voxel, and pass them through a simple train/test cross-validation classification. The generalization score will be that center voxel's 'goodness' value (just as the ANOVA p value in STATMAP\_ANOVA.M provides a goodness value).

The only tricky part about this pertains to peeking. We
can't allow our multivariate statistical test to ever see
the test data that we will eventually use for computing our
final classification generalization score in
CROSS\_VALIDATION.M. Of course, if all you want is a brain
map, and don't plan to run classification on the resulting
mask, then this isn't a problem at all. However, we will
assume that your aim is to define a set of masks that you
will later use in an n-1 leave-one-out classification
design, such as Haxby et al (2001), avoiding any kind of
peeking. In order to make it easy to tell what's what, we will use a backprop classifier for the final cross-validation analysis, as in TUTORIAL\_EASY.M.

As usual, to avoid any kind of peeking impropriety, we'll
divide our dataset data up into parts with a group of
cross-validation selectors. Unusually though, each iteration
of cross-validation, we are going to divide the dataset into
3 parts:

  * training data (1s) - for training the searchlight GNB, and also for training the backprop classifier in the final cross-validation analysis

  * final-testing data (2s) - for testing the backprop classifier in the final cross-validation. The searchlight GNB will not see this data. The generalization performance on this final-testing data is the final classification score that we're trying to optimize.

  * searchlight-generalization data (3s) - for testing the searchlight GNB. The generalization performance on this searchlight-generalization data will be used as the  goodness value for the center voxel in each sphere. So,really, it is a kind of 'training' data too, since it's part of the data we will use for feature selection.

As you can probably see, the 1s and 2s have not changed
their meaning. It is only the addition of the 3s that is new
here. Remember - the GNB's goodness value will be determined
by the searchlight-generalization data, but the
final-testing data will play no role whatsoever in feature
selection or preparation.


First, run [:TutorialIntro:TUTORIAL\_EASY.M] to create your SUBJ structure. This should leave you with a SUBJ structure that looks something like this:

```
>> summarize(subj)

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

To keep things nice and simple, let's abandon our
painstakingly-created ANOVA maps & masks, since they're only going
to get in the way for this tutorial, and also the
cross-validation indices that we created, since we're going
to need new ones:

```
subj = remove_group(subj,'pattern','epi_z_anova');
subj = remove_group(subj,'mask','epi_z_thresh0.05');
subj = remove_group(subj,'selector','runs_xval');
```

It is always so much easier to destroy than create.

```
>> summarize(subj)

Subject 'tutorial_subj' in 'haxby8' experiment

Patterns -                                              [ nVox x nTRs]
    1) epi                            -                 [  577 x 1210]
    2) epi_z                          -                 [  577 x 1210]

Regressors -                                            [nCond x nTRs]
    1) conds                          -                 [    8 x 1210]

Selectors -                                             [nCond x nTRs]
    1) runs                           -                 [    1 x 1210]

Masks -                                                 [ X  x  Y  x  Z ] [ nVox]
    1) VT_category-selective          -                 [ 64 x  64 x  40] [  577]
```

Now, we need to create our group of cross-validation
selectors. There will be one for each iteration of the
cross-validation process. For each iteration, we're going to
withhold one run for final-test data (as usual), we'll
withhold one run for searchlight-generalization data, and
we'll use the remainder for training data. We could do this
by modifying the output of CREATE\_XVALID\_INDICES.M using
RUNS as the selector, but instead, we'll create them from
scratch with our bare hands, since it's not too hard.

```
runs = get_mat(subj,'selector','runs');
nRuns = max(runs);
nTimepoints = length(runs);

runs_xval_sl = ones(nRuns,nTimepoints);

for r=1:nRuns
  cur_final_test_run = find(runs==r);
  runs_xval_sl(r, cur_final_test_run) = 2;
end

imagesc(runs_xval_sl)
set(gca,'CLim',[1 3])
colorbar
```

Ok. So far so good. You should see a plot where each run is
a row, and each column is a timepoint. The blue areas are
the training data (1s). The green areas are the final-testing
data (2s). This is more or less what CREATE\_XVALID\_INDICES.M
creates.

[Most of the above code should be pretty clear. The only
line that's at all fiendish is the one beginning with
set(gca,...). Basically, this says to Matlab that we're
going to plot some 3s in a minute, so it should scale the
colorbar to leave room for them. That's why the 2s are
green.]

Now, time to label the searchlight-generalization
timepoints with 3s (which will be red).

```
for r=1:nRuns
  cur_searchlight_gen_run = find(runs== nRuns-r+1);
  runs_xval_sl(r, cur_searchlight_gen_run) = 3;
end

imagesc(runs_xval_sl)
colorbar
```

So, for instance, in the first iteration of
cross-validation, we're going to train both the GNB and
backprop on runs 2:9 (inclusive). We're going to evaluate
the GNB's searchlight-generalization on run 10. And we're
going to final-test backprop on run 1.

Our choice of which run will be withheld for
searchlight-generalization is entirely arbitrary here. At
the end of this tutorial, we consider alternative ways to
pick out the searchlight-generalization timepoints to
withhold.

Finally, let's add each row from this matrix to the toolbox
as a separate selector object, and then group them together,
so they're ready to be fed to FEATURE\_SELECT.M and
CROSS\_VALIDATION.M.

```
for r=1:nRuns
  cur_name = sprintf('runs_xval_sl_%i',r);
  subj = initset_object(subj, 'selector', cur_name, ...
                        runs_xval_sl(r,:), ...
                        'group_name', 'runs_xval_sl' );
end
```

The INITSET\_OBJECT.M function is handy - it's like running
INIT\_OBJECT.M, SET\_MAT.M and then SET\_OBJFIELD.M all in one
go. Let's check that everything's been added correctly:

```
>> summarize(subj)

Subject 'tutorial_subj' in 'haxby8' experiment

Patterns -                                              [ nVox x nTRs]
    1) epi                            -                 [  577 x 1210]
    2) epi_z                          -                 [  577 x 1210]

Regressors -                                            [nCond x nTRs]
    1) conds                          -                 [    8 x 1210]

Selectors -                                             [nCond x nTRs]
    1) runs                           -                 [    1 x 1210]
    2) runs_xval_sl_1                 -   [GRP size 10] [    1 x 1210]
    3) runs_xval_sl_2                 -   [GRP size 10] [    1 x 1210]
    4) runs_xval_sl_3                 -   [GRP size 10] [    1 x 1210]
    5) runs_xval_sl_4                 -   [GRP size 10] [    1 x 1210]
    6) runs_xval_sl_5                 -   [GRP size 10] [    1 x 1210]
    7) runs_xval_sl_6                 -   [GRP size 10] [    1 x 1210]
    8) runs_xval_sl_7                 -   [GRP size 10] [    1 x 1210]
    9) runs_xval_sl_8                 -   [GRP size 10] [    1 x 1210]
   10) runs_xval_sl_9                 -   [GRP size 10] [    1 x 1210]
   11) runs_xval_sl_10                -   [GRP size 10] [    1 x 1210]

Masks -                                                 [ X  x  Y  x  Z ] [ nVox]
    1) VT_category-selective          -                 [ 64 x  64 x  40] [  577]
```

Looks good. That's the hardest part out of the way.

The next step is to create our 'adjacency
matrix'. Basically, this defines the spherical searchlight
neighborhood for each voxel. It's a matrix, where each row
contains the indices of all the voxels within a predefined
radius. These indices are relative to the pattern.

Creating the adjacency matrix isn't too hard:

```
>> subj.adj_sphere = create_adj_list(subj,'VT_category-selective');
create_adj_list: creating 'adj_sphere' adjacency list of mask 'VT_category-selective'
        Sphere radius = 2.0
Creating spherical envelope...
Transforming mask indices into subscripts...
Passing the sphere over each voxel...
        ...  10%  20%  30%  40%  49%  59%  69%  79%  89%  99%  100%  done

```

Kaboom! Don't you feel great? Did you ever guess when you
woke up this morning that you'd be creating adjacency
matrices left, right and center before breakfast?

Enough smugness for now. The main complication you might
want to consider would be to change the radius of the
sphere. In that case, you'd want to pass in a RAADIUS
argument, e.g.

```
>> subj.adj_sphere = create_adj_list(subj,'VT_category-selective','radius',1);
```

You should find that ADJ\_LIST will have fewer columns in
this latter case. That makes sense - the smaller the radius,
the fewer voxels in each spherical neighborhood, and so the
fewer indices on each row of the adjacency matrix. Let's examine one row:

```
>> subj.adj_sphere(1,:)

ans =

     1    12     0     0     0     0     0
```

There are a few things to note from this:

  * The first voxel, 1, is included in its own spherical neighborhood. That makes sense, since it would be strange to give this voxel a goodness value for a statistical test that ignored it. It also means that even zero-radius spheres will contain a single voxel.

  * The 12th voxel in the pattern is the only other voxel in this spherical neighborhood.

  * There are no other voxels in this voxel's spherical neighborhood. The matrix is zero-padded, so the number of columns grows to fit the largest neighborhood. Why would this neighborhood be so small? Perhaps this voxel is near the edge of the volume, in which case the sphere will be truncated. More likely though, the rest of the voxels that would have been in this neighborhood have been excluded by our mask, which is pretty small (only 577 voxels). In other words, if a voxel isn't included in this pattern's mask, it won't be included in any of the spheres.

  * The largest spherical neighborhood for this mask and this radius is 7.

See CREATE\_ADJ\_LIST.M and ADJ\_SPHERE.M for more information
on creating the adjacency matrix.

Now, we have almost all the pieces for our FEATURE\_SELECT.M
call, which is going to look like this:

```
subj = feature_select( ...
    subj, ...
    'epi_z', ... % data
    'conds', ... % binary regs (for GNB)
    'runs_xval_sl', ... % selector
    'statmap_funct','statmap_searchlight', ... % function
    'statmap_arg',statmap_srch_arg, ...
    'new_map_patname','epi_z_srch', ...
    'thresh',[]);
```

But wait! Don't run it yet... Too late? No harm done. We
don't yet have a 'statmap\_srch\_arg' options structure yet.

```
class_args.train_funct_name = 'train_gnb';
class_args.test_funct_name = 'test_gnb';

scratch.class_args = class_args;
scratch.perfmet_args = struct([]);

statmap_srch_arg.adj_list = subj.adj_sphere;
statmap_srch_arg.obj_funct = 'statmap_classify';
statmap_srch_arg.scratch = scratch;
```

As you can see, the 'statmap\_srch\_arg' structure is kind of
like an onion that's going to get unpeeled
layer-by-layer:

  * the outer 'statmap\_srch\_arg' layer contains arguments for STATMAP\_SEARCHLIGHT.M. This is where we feed in the adjacency matrix, SUBJ.ADJ\_SPHERE, and where we specify that we're going to use STATMAP\_CLASSIFY to run a classifier. In Kriegeskorte, Bandettini & Goebel (2006), they use Mahalanobis distance. You might want to try a MANOVA (though we haven't implemented a MANOVA for the toolbox).

  * the 'scratch' structure gets passed on to STATMAP\_CLASSIFY.M, which is a sort of stripped-down version of CROSS\_VALIDATION.M. It trains and tests the classifer on the timepoints picked out by the xval selector's 1s and 3s for that iteration.

  * and then the 'class\_args' structure gets passed to TRAIN\_GNB.M, as usual.

Phew. We have some ideas for simplifying this in the future,
but for now, this system works, and gives us a lot of flexibility. If you wanted, you could drop in:

  * a different classifier (e.g. TRAIN\_RIDGE) or performance metric (e.g. PERFMET\_XCORR)

  * a completely different statistical test (e.g. a MANOVA or STATMAP\_GLM\_MULTIV)

  * a different shaped searchlight neighborhood

So, putting that all together, we're ready to go:

```
class_args.train_funct_name = 'train_gnb';
class_args.test_funct_name = 'test_gnb';

scratch.class_args = class_args;
scratch.perfmet_funct = 'perfmet_maxclass';
scratch.perfmet_args = struct([]);

statmap_srch_arg.adj_list = subj.adj_sphere;
statmap_srch_arg.obj_funct = 'statmap_classify';
statmap_srch_arg.scratch = scratch;

subj = feature_select( ...
    subj, ...
    'epi_z', ... % data
    'conds', ... % binary regs (for GNB)
    'runs_xval_sl', ... % selector
    'statmap_funct','statmap_searchlight', ... % function
    'statmap_arg',statmap_srch_arg, ...
    'new_map_patname','epi_z_srch', ...
    'thresh',[]);

Starting 10 statmap_searchlight iterations
  1     ...  10%  20%  30%  40%  49%  59%  69%  79%  89%  99%  100%  done

  2     ...  10%  20%  30%  40%  49%  59%  69%  79%  89%  99%  100%  done

  3     ...  10%  20%  30%  40%  49%  59%  69%  79%  89%  99%  100%  done

  4     ...  10%  20%  30%  40%  49%  59%  69%  79%  89%  99%  100%  done

  5     ...  10%  20%  30%  40%  49%  59%  69%  79%  89%  99%  100%  done

  6     ...  10%  20%  30%  40%  49%  59%  69%  79%  89%  99%  100%  done

  7     ...  10%  20%  30%  40%  49%  59%  69%  79%  89%  99%  100%  done

  8     ...  10%  20%  30%  40%  49%  59%  69%  79%  89%  99%  100%  done

  9     ...  10%  20%  30%  40%  49%  59%  69%  79%  89%  99%  100%  done

  10    ...  10%  20%  30%  40%  49%  59%  69%  79%  89%  99%  100%  done


Pattern statmap group 'epi_z_srch' and mask group 'epi_z_thresh' created by feature_select
>> summ

Subject 'tutorial_subj' in 'haxby8' experiment

Patterns -                                              [ nVox x nTRs]
    1) epi                            -                 [  577 x 1210]
    2) epi_z                          -                 [  577 x 1210]
    3) epi_z_srch_1                   -   [GRP size 10] [  577 x    1]
    4) epi_z_srch_2                   -   [GRP size 10] [  577 x    1]
    5) epi_z_srch_3                   -   [GRP size 10] [  577 x    1]
    6) epi_z_srch_4                   -   [GRP size 10] [  577 x    1]
    7) epi_z_srch_5                   -   [GRP size 10] [  577 x    1]
    8) epi_z_srch_6                   -   [GRP size 10] [  577 x    1]
    9) epi_z_srch_7                   -   [GRP size 10] [  577 x    1]
   10) epi_z_srch_8                   -   [GRP size 10] [  577 x    1]
   11) epi_z_srch_9                   -   [GRP size 10] [  577 x    1]
   12) epi_z_srch_10                  -   [GRP size 10] [  577 x    1]

Regressors -                                            [nCond x nTRs]
    1) conds                          -                 [    8 x 1210]

Selectors -                                             [nCond x nTRs]
    1) runs                           -                 [    1 x 1210]
    2) runs_xval_sl_1                 -   [GRP size 10] [    1 x 1210]
    3) runs_xval_sl_2                 -   [GRP size 10] [    1 x 1210]
    4) runs_xval_sl_3                 -   [GRP size 10] [    1 x 1210]
    5) runs_xval_sl_4                 -   [GRP size 10] [    1 x 1210]
    6) runs_xval_sl_5                 -   [GRP size 10] [    1 x 1210]
    7) runs_xval_sl_6                 -   [GRP size 10] [    1 x 1210]
    8) runs_xval_sl_7                 -   [GRP size 10] [    1 x 1210]
    9) runs_xval_sl_8                 -   [GRP size 10] [    1 x 1210]
   10) runs_xval_sl_9                 -   [GRP size 10] [    1 x 1210]
   11) runs_xval_sl_10                -   [GRP size 10] [    1 x 1210]

Masks -                                                 [ X  x  Y  x  Z ] [ nVox]
    1) VT_category-selective          -                 [ 64 x  64 x  40] [  577]
```

That just trained and tested the classifier 5770 times (577 voxels, 10 iterations). For a given voxel on a given iteration, its spherical neighborhood's searchlight-generalization performance is stored as the center voxel's statmap value.

And now, to create masks from the statmaps, by picking the
best 200 values in each statmap:

```
subj = create_sorted_mask( ...
    subj,'epi_z_srch', ...
    'epi_z_srch_200',200, ...
    'descending',true);    
```

High searchlight-generalization performance is better, so
make sure to note the 'descending' argument.

Finally, let's try n-1 classification, using a separate mask for each iteration. None of the algorithms so far have used the 2s timepoints from our RUNS\_XVAL\_SL group, so there's no peeking involved. Aside from the masks, we'll use the same parameters as for TUTORIAL\_EASY.M.

```
>> class_args.train_funct_name = 'train_bp';
>> class_args.test_funct_name = 'test_bp';
>> class_args.nHidden = 0;

>> [subj results] = cross_validation( ...
                                     subj, ...
                                     'epi_z', ... % data
                                     'conds', ... % regressors
                                     'runs_xval_sl', ... % xval selectors
                                     'epi_z_srch_200', ... % mask group
                                     class_args);
```

## Visualization ##

The searchlight analysis should return a pattern (just like the anova and other feature selection methods), which contains the results of running the searchlight analysis centered on each individual voxel. In other words, each sphere is centered on a different voxel. The score for a given sphere is assigned to its center-voxel, and stored in the pattern's nVox x 1 matrix.

You can visualize this pattern with view\_montage, just like you can visualize the p values from the anova. See TutorialVisualization for more information on visualizing brainmaps.


## Conclusion ##

Congratulations! That should be enough to get you started
running your own searchlight analyses. All of the functions
discussed here have their own help, which often goes into
more detail.


## Further questions ##

We opted for a simple strategy when choosing which timepoints to use for searchlight-generalization, and which to use for final-testing, by fixing a single run per iteration for each. One could imagine various alternative strategies, perhaps involving randomization. At this stage, we have not implemented anything along these lines.

At the time of writing, the only multivariate algorithms
that can be run within a sphere are STATMAP\_CLASSIFY and
STATMAP\_GLM\_MULTIV. See their help for more
information. Writing new ones wouldn't be too hard if you
use them as a template.

TODO:

> converting between mask and pattern indices