# Using AFNI's GLM (3dDeconvolve) for voxel selection #

Note: the functionality in this section relies on AFNI's 3dDeconvolve GLM function being called from within Matlab automatically by the MVPA toolbox. We don't even try to cover the range of options and intricacies involved in running a proper GLM on neuroimaging data in this document. Please please try running a GLM with AFNI first, by hand, before attempting to automate the process here. This functionality is still evolving slowly, so [:mvpa-toolbox@googlegroups.com let us know](mailto.md) if any of the functions you need haven't been included in the release version you have, or if things don't work as they should.

Using a GLM rather than an ANOVA makes a lot more sense, because you can use convolved (rather than binary) regressors, and you can also add 'regressors of no interest' (e.g. motion regressors). This requires some familiarity with standard AFNI functionality, especially 3dDeconvolve, which we do not explain in detail here.

Before you start, you'll need to find or create the BRIK file for the data to feed into the GLM. It needs to be a single BRIK containing all the timepoints from all the runs. The BRIK file from which you originally loaded your pattern is probably the right choice. You may need to use [3dTcat](http://afni.nimh.nih.gov/pub/dist/HOWTO/howto/ht02_DDmb/html/AFNI_howto.shtml) to concatenate all the separate runs together. Ideally, the data should not have been z-scored or detrended. For instance, to concatenate all the BRIKs of the Haxby et al (2001) sample data, run the following in a shell:

```
$ 3dTcat \
-prefix haxby8_all+orig \
haxby8_r1+orig.BRIK \
haxby8_r2+orig.BRIK \
haxby8_r3+orig.BRIK \
haxby8_r4+orig.BRIK \
haxby8_r5+orig.BRIK \
haxby8_r6+orig.BRIK \
haxby8_r7+orig.BRIK \
haxby8_r8+orig.BRIK \
haxby8_r9+orig.BRIK \
haxby8_r10+orig.BRIK
```

Next, find the BRIK file for the mask you want to use (e.g. intra-cranial mask). Alternatively, use WRITE\_TO\_AFNI.M to write out a mask from the SUBJ structure. The sample data in the toolbox includes a wholebrain mask (created using AFNI's [3dAutomask](http://afni.nimh.nih.gov/pub/dist/doc/program_help/3dAutomask.html)), called 'wholebrain+orig'.

So now, we're ready to specify the name of the BRIK containing all our data (which we just created with 3dTcat above) and our mask (e.g. an intracranial mask, defined with 3dAutomask).

```
>> statmap_3d_arg.whole_func_name = 'haxby8_all+orig';
>> statmap_3d_arg.deconv_args.mask = 'wholebrain+orig';
```

Note: if your AFNI data files are stored in a different path (e.g. an 'afni' subdirectory), then prepend that path to the beginning of all the filenames, so 'haxby8\_all+orig' would become 'afni/haxby8\_all+orig'. This function assumes that you have convolved your regressors, and have a CONDS\_CONV regressors object (see section above).

Next, we need to feed it information about our runs. [statmap\_3dDeconvolve.m](http://code.google.com/p/princeton-mvpa-toolbox/source/browse/trunk/core/preproc/statmap_3dDeconvolve.m) will automatically write out a startpoints.1d text file, containing zero-indexed information about when the runs start. This is important, because the GLM automatically creates baseline regressors that model baseline shifts between runs, as well as linear and quadratic scanner drift within a run. That's more or less what the POLORT argument of 2 is specifying, and that's why we don't need to worry about using z-scored or detrended data.

```
>> statmap_3d_arg.runs_selname = 'runs';
>> statmap_3d_arg.deconv_args.polort = '2';
```

Now comes the main bit of wizardry. A standard GLM's F values tell you how much of the variance the complete model was able to account for for in the voxel timecourse. But that's not quite what we want. Really, we want to know whether the the betas for each condition differ from one another. We want to take the virtues of the GLM (modelling convolved regressors, modelling trends, modelling motion parameters etc.), but run a statistical test along the lines of an ANOVA. AFNI's 'general linear test' contrast machinery allows us to do that. We aren't going to discuss this in detail here. The key point is that the [create\_main\_effect\_contrast.m](http://code.google.com/p/princeton-mvpa-toolbox/source/browse/trunk/core/preproc/create_main_effect_contrast.m) function multiplies your regressors with a contrast matrix before writing them out, so that the full F-stat values that we pull from the AFNI GLM bucket BRIK are actually really ANOVA-like contrast values.

```
>> nConds = size(get_mat(subj,'regressors','conds'),1);
>> statmap_3d_arg.contrast_mat = create_main_effect_contrast(nConds);
```

To examine this contrast matrix further, you could peek at the output of:

```
create_main_effect_contrast(8)
```

The one important thing to remember is that you will only have 7 regressors after your regressors have been multiplied by this contrast matrix. This should minimize issues with multicollinearity.

There are many ways to skin an 8-way general linear model of a cat. We might change the way this works in the future. Let us know if you have any ideas for how to do this in a more straightforward manner.

Unfortunately, we're going to get some warnings, because of the fact that we're censoring out an entire run at a time (see below). In order to tell the GLM to run roughshod over them, we need the following line. N.B. we're trying to fix this issue for the future. In the meantime, please be careful when using the 'goforit', since you may inadvertently be ignoring more serious issues.

```
statmap_3d_arg.goforit = 7;
```

Now, you're ready to run [feature\_select.m](http://code.google.com/p/princeton-mvpa-toolbox/source/browse/trunk/core/preproc/feature_select.m) and [statmap\_3dDeconvolve.m](http://code.google.com/p/princeton-mvpa-toolbox/source/browse/trunk/core/preproc/statmap_3dDeconvolve.m). The following commands will run an n-minus-one voxel selection using 3dDeconvolve, which will create a bucket BRIK. The last sub-brik of this bucket will contain the full F-stat value for each voxel, and it is these F values that get used to choose voxels. 3dDeconvolve will get run n times, once for each iteration, each time using a different censor file. Only timepoints marked with 1s in the RUNS\_XVAL selectors will be used on each iteration, so the GLM will never take your test data into account when building its model or selecting voxels.

```
>> subj = feature_select(subj,'epi_z', ...
                         'conds_conv','runs_xval', ...
                         'thresh',[], ...
                         'statmap_funct','statmap_3dDeconvolve', ...
                         'statmap_arg', statmap_3d_arg);
```

If you remembered to [sacrifice a goat](http://news.bbc.co.uk/2/hi/south_asia/6979292.stm) of the requisite pedigree, you should see the following appear (followed by lots of output from 3dDeconvolve itself):

```
Starting 10 statmap_3dDeconvolve iterations
  1Writing regressors to conds_conv_it1_c#.1d files
Wrote the following to mvpa_3dDeconvolve_1.sh
---------------------------------------
3dDeconvolve \
-input haxby8_all+orig \
-concat startpoints.txt \
-num_stimts 7 \
-xjpeg mvpa_3dDeconvolve_1.sh.jpg \
-stim_file 1 conds_conv_it1_c1.1d -stim_label 1 conds_conv_c1 \
-stim_file 2 conds_conv_it1_c2.1d -stim_label 2 conds_conv_c2 \
-stim_file 3 conds_conv_it1_c3.1d -stim_label 3 conds_conv_c3 \
-stim_file 4 conds_conv_it1_c4.1d -stim_label 4 conds_conv_c4 \
-stim_file 5 conds_conv_it1_c5.1d -stim_label 5 conds_conv_c5 \
-stim_file 6 conds_conv_it1_c6.1d -stim_label 6 conds_conv_c6 \
-stim_file 7 conds_conv_it1_c7.1d -stim_label 7 conds_conv_c7 \
-censor censor_epi_z_it1.1d \
-bucket epi_z_it1_bucket+orig \
-num_glt 7 \
-gltsym 'SYM:  +conds_conv_c1 \ +conds_conv_c2 \ +conds_conv_c3 \ +conds_conv_c4 \ +conds_conv_c5 \ +conds_conv_c6 \ +conds_conv_c7 ' -glt_label 1 statmap_3dDeconvolve \
-mask wholebrain+orig \
-polort 2 \
-fout

...
```

This is going to run the GLM 10 times, each time automatically censoring all but the training data. It should have written a boolean censor file (1s = include, 0s = exclude) called 'censor\_epi\_z\_it1.1d'. Check that it looks correct. It has also written out all the CONDS\_CONV regressors. These will look strange, because they've been pre-multiplied by the contrast matrix. 'mvpa\_3dDeconvolve\_1.sh.jpg' shows your design matrix. Most of the first few columns are baseline and trend regressors. Notice the two all-black columns - those are the trend regressors for the run we censored out in its entirety. The last 7 columns are your regressors, after being multiplied by the contrast matrix.

You should take some time to inspect the output of the 3dDeconvolve. It doesn't like the fact that two of the regressor columns are all zeros, because we censored out an entire run - so the baseline regressors for that run are all zeros. However, this warning should be pretty benign.

At the end of this, you should end up with a statmap for
each iteration. The optional 'thresh' argument set to empty
told _feature/_select.m_not to try to create masks
automatically by thresholding the statmaps. This is because
at the moment, we haven't added functionality for extracting
a p value from the GLM F values, and so there's no way to
know what threshold value to use._


At the end of all this, your patterns should look something like this:

```
>> summarize(subj,'objtype','pattern')

Subject 'tutorial_subj' in 'haxby8' experiment

Patterns -                                    [ nVox x nTRs]
    1) epi                    -               [  577 x 1210]
    2) epi_z                  -               [  577 x 1210]
    3) epi_z_3dDeconvolve_1   - [GRP size 10] [  577 x    1]
    4) epi_z_3dDeconvolve_2   - [GRP size 10] [  577 x    1]
    5) epi_z_3dDeconvolve_3   - [GRP size 10] [  577 x    1]
    6) epi_z_3dDeconvolve_4   - [GRP size 10] [  577 x    1]
    7) epi_z_3dDeconvolve_5   - [GRP size 10] [  577 x    1]
    8) epi_z_3dDeconvolve_6   - [GRP size 10] [  577 x    1]
    9) epi_z_3dDeconvolve_7   - [GRP size 10] [  577 x    1]
   10) epi_z_3dDeconvolve_8   - [GRP size 10] [  577 x    1]
   11) epi_z_3dDeconvolve_9   - [GRP size 10] [  577 x    1]
   12) epi_z_3dDeconvolve_10  - [GRP size 10] [  577 x    1]
```

There are many other optional arguments that
_statmap\_3dDeconvolve.m_ accepts, as detailed in the
help.

However, 3dDeconvolve accepts an obscene number of
arguments, so there are bound to be some that you want to
use that don't have an explicit optional argument in
statmap\_3dDeconvolve. For instance, let's imagine that we
also want 3dDeconvolve to write out the t values as
sub-briks, using the '-tout' argument. In that case, add the
following to your STATMAP\_3D\_ARG:

```
statmap_3d_arg.deconv_args.tout = '';
```

This will manifest itself in the shell script as:

```
-tout  \
```

You can fill the DECONV\_ARGS structure with any extra
arguments that you'd like to be passed
in. STATMAP\_3DDECONVOLVE will prepend a hyphen to the
fieldname, and then write out the value of the field as
well. So the lines that we used above:

```
>> statmap_3d_arg.deconv_args.mask = 'wholebrain+orig';
>> statmap_3d_arg.deconv_args.polort = '2';
```

showed up in the shell script as:

```
-mask wholebrain+orig \
-polort 2 \
```

In this way, you can create more or less any 3dDeconvolve script through the STATMAP\_3DDECONVOLVE interface. Currently, the main exception to this is the way that general linear tests (GLTs, in AFNI parlance) are created. At the moment, the GLTs are hard-coded, and assume that you're using CREATE\_MAIN\_EFFECTS\_CONTRAST to first multiply your regressors with a contrast matrix.

See AFNI's [3dDeconvolve](http://afni.nimh.nih.gov/afni/doc/howto/2) function and [statmap\_3dDeconvolve.m](http://code.google.com/p/princeton-mvpa-toolbox/source/browse/trunk/core/preproc/statmap_3dDeconvolve.m) for more information.


## Create\_sorted\_mask ##

Because we didn't threshold the statmaps, we're going to (somewhat arbitrarily) choose the best 200 voxels and just keep them.

```
>> subj = create_sorted_mask(subj,'epi_z_3dDeconvolve', ...
                             '3dD_200',200, ...
                             'descending',true);
```

[create\_sorted\_mask.m](http://code.google.com/p/princeton-mvpa-toolbox/source/browse/trunk/core/preproc/create_sorted_mask.m) and [create\_thresh\_mask.m](http://code.google.com/p/princeton-mvpa-toolbox/source/browse/trunk/core/preproc/create_thresh_mask.m) do more or less the same thing - they take continuous-valued statmaps and turn them into binary masks. The former returns a fixed number of voxels, whereas the latter uses a threshold to decide which to include/exclude. The above command will take the 'epi\_z\_3dDeconvolve' statmap and creates a mask called '3dD\_200' containing the best 200 voxels (where bigger = better). Because 'epi\_z\_3dDeconvolve' is the name of the group of statmaps, this will run on every member of the group, creating a corresponding mask for each.

```
>> summarize(subj,'objtype','mask')

Subject 'tutorial_subj' in 'haxby8' experiment

Masks -                                        [ X  x  Y  x  Z ] [ nVox]
    1) VT_category-selective -                 [ 64 x  64 x  40] [  577]
    2) 3dD_200_1             -   [GRP size 10] [ 64 x  64 x  40] [  200]
    3) 3dD_200_2             -   [GRP size 10] [ 64 x  64 x  40] [  200]
    4) 3dD_200_3             -   [GRP size 10] [ 64 x  64 x  40] [  200]
    5) 3dD_200_4             -   [GRP size 10] [ 64 x  64 x  40] [  200]
    6) 3dD_200_5             -   [GRP size 10] [ 64 x  64 x  40] [  200]
    7) 3dD_200_6             -   [GRP size 10] [ 64 x  64 x  40] [  200]
    8) 3dD_200_7             -   [GRP size 10] [ 64 x  64 x  40] [  200]
    9) 3dD_200_8             -   [GRP size 10] [ 64 x  64 x  40] [  200]
   10) 3dD_200_9             -   [GRP size 10] [ 64 x  64 x  40] [  200]
   11) 3dD_200_10            -   [GRP size 10] [ 64 x  64 x  40] [  200]
```