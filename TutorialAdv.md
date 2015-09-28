# Advanced tutorial #




---



## Introduction ##

If you've effortlessly floated through TutorialIntro, the first thing to do is to grab a data set of your own and try rewriting tutorial\_easy.m to work with your data.

If you've done that, then you're probably looking for something else to get your teeth into - you're in the right place. This tutorial assumes that you have already been through TutorialIntro. We recommend messing around with some of your own data for a little bit before moving on to this one, since it assumes familiarity with most of the basic procedures, e.g. get/set functions, loading in data from AFNI, and the basic n-minus-one voxel selection and classification procedure. Hopefully, after reading this you'll feel much more comfortable about what's going on behind the scenes, and be in a better position to tailor your analysis procedures to your design and hypotheses.

As before, this will rely on the AFNI dataset from Haxby et al (Science, 2001) that is provided with the toolbox.

For further information, see the main documentation in the [Manual](Manual.md), or [Glossary](Glossary.md) for unfamiliar terms.


## What you will need to start with ##

If you were able to successfully run tutorial\_easy.m, you should have everything you need to run this. You might benefit from having the ["Manual"] open in a nearby window as you read this.


## Creating wholebrain and wholevol masks ##

In TutorialIntro, we loaded in a pre-made mask using the following command:

```
>> subj = load_afni_mask(subj,'VT_category-selective','mask_cat_select_vt+orig');
```

This created an object called 'VT\_category-selective' by loading in a BRIK file called 'mask\_cat\_select\_vt+orig.BRIK'. For tutorial purposes, this worked well, since it only included 577 voxels, and we knew that they would give decent classification performance. However, this mask was actually the intersection of an anatomical ventral temporal mask and an omnibus ANOVA/GLM to find voxels that differed in their activity between categories. In other words, using this mask was cheating ('peeking'), because it took the test data into account when selecting voxels. See ["Manual"] / Pre-classification / Peeking for more information.

If we're going to do things properly, we should start with an anatomically-defined mask and then do our statistical voxel selection for each iteration of the n-minus-one separately. Depending on our purposes, we might start with a basic ventral temporal mask, or an entire intra-cranial ('wholebrain') mask. This section describes how to load in such a mask.

Just for kicks, let's start by trying to load in every single voxel of our data from the volume that the scanner picks up. To do this, we have to create a 'wholevol' mask:

```
>> wholevol = ones(64,64,40);

>> subj = initset_object(subj,'mask','wholevol',wholevol);

>> for i=1:10
     raw_filenames{i} = sprintf('haxby8_r%i+orig',i);
   end

>> subj = load_afni_pattern(subj,'epi','wholevol',raw_filenames);
```

This will almost certainly make your computer burp with rage and frustration, because we're trying to create a matrix that contains 198,246,400 elements (64 x 64 x 40 x 1210). Ah well. Try again in 5 years' time.

See ''["Manual"] / Howtos / Masks / Creating a wholevol mask'' for more information.

Instead, let's try and load in a wholebrain (i.e. intra-cranial) mask. There should be a pre-made one hiding amidst the data BRIKs called ''wholebrain+orig.BRIK''. All you need to do is load it in using LOAD\_AFNI\_MASK.M, just as we did in TutorialIntro:

```
>> subj = load_afni_mask(subj,'wholebrain','wholebrain+orig'); 

>> summarize(subj,'objtype','mask')

Subject 'tutorial_subj' in 'haxby8' experiment

Masks - [ X x Y x Z ] [ nVox]

1) VT_category-selective -  [ 64 x 64 x 40] [ 577]

2) epi_z_thresh0.05_1 - [GRP size 10] [ 64 x 64 x 40] [ 577]

3) epi_z_thresh0.05_2 - [GRP size 10] [ 64 x 64 x 40] [ 574]

4) epi_z_thresh0.05_3 - [GRP size 10] [ 64 x 64 x 40] [ 573]

5) epi_z_thresh0.05_4 - [GRP size 10] [ 64 x 64 x 40] [ 571]

6) epi_z_thresh0.05_5 - [GRP size 10] [ 64 x 64 x 40] [ 575]

7) epi_z_thresh0.05_6 - [GRP size 10] [ 64 x 64 x 40] [ 575]

8) epi_z_thresh0.05_7 - [GRP size 10] [ 64 x 64 x 40] [ 573]

9) epi_z_thresh0.05_8 - [GRP size 10] [ 64 x 64 x 40] [ 575]

10) epi_z_thresh0.05_9 - [GRP size 10] [ 64 x 64 x 40] [ 573]

11) epi_z_thresh0.05_10 - [GRP size 10] [ 64 x 64 x 40] [ 574]

12) wholebrain - [ 64 x 64 x 40] [43193] 
```

Notice that we've used an optional argument in our call to SUMMARIZE.M, instructing it to show us only mask objects. The final object is called 'wholebrain', and contains 43193 voxels. This will be the mask that we'll use from now on.

See [Manual](Manual.md) / Howtos / Masks / Creating a wholebrain (intra-cranial) mask.


## Taking the haemodynamic lag into account ##

In ''[Manual](Manual.md) / Howtos / Regressors / How can I take the haemodynamic lag into account'', two methods are described:

1. shifting the regressors along by a few timepoints ([''shift\_regressors.m''](http://code.google.com/p/princeton-mvpa-toolbox/source/browse/trunk/core/preproc/shift_regressors.m))

2. convolving the regressors with a model of the haemodynamic response function ([''convolve\_regressors\_afni.m''](http://code.google.com/p/princeton-mvpa-toolbox/source/browse/trunk/core/preproc/convolve_regressors_afni.m))


### Shifting the regressors along ###

This is pretty easy. The TR (time to repetition of each image) for the Haxby et al. (2001) experiment was 2 seconds, and the haemodynamic response should peak around 5 seconds after stimulus onset, so we'll shift 3 timepoints along:

UPDATE: there's an error in the above paragraph. The actual TR size is 2.5s, so we might actually be better off shifting by just 2 TRs.

```
>> subj = shift_regressors(subj,'conds','runs',3); 

>> summarize(subj,'objtype','regressors')

Subject 'tutorial_subj' in 'haxby8' experiment

Regressors - [nCond x nTRs]

1) conds - [ 8 x 1210]

2) conds_shifted3 - [ 8 x 1210]

>> conds = get_mat(subj,'regressors','conds');

>> conds_shifted3 = get_mat(subj,'regressors','conds_shifted3');

>> conds(:,1:10)

ans =

1 1 1 1 1

>> conds_shifted3(:,1:10)

ans =

1 1 
```

This created a new regressors object called 'conds\_shifted3'. As can be seen from comparing the first 10 timepoints of the 'conds' and 'conds\_shifted3' matrix, the new regressors matrix has been shifted 3 TRs along in time relative to the data. If you want to better visualize this, especially how it deals with each run separately, use ''imagesc'':

```
>> figure 

>> subplot(2,1,1)

>> imagesc(conds(:,1:150))

>> subplot(2,1,2)

>> imagesc(conds_shifted3(:,1:150)) 
```

See ["Manual"] / Regressors / How can I shift my regressors along for more information about what's going on.


### Convolving the regressors with a model of the haemodynamic response function ###

We will focus on this latter method, since in almost all instances it should be a better model. Unfortunately, it requires AFNI and the ''waver'' function to work. If you don't have access to AFNI, then you'll need to use another program to convolve the regressors, save them out as text files, load them in to Matlab normally, and then use INITSET\_OBJECT.M to put them into a regressors object (much as we loaded in ''tutorial\_regs.mat'' in ''tutorial\_easy.htm'').

Rather than just shifting the regressors along, it's usually better to convolve them with a model of the haemodynamic response function. If you have AFNI, the ''waver'' function will do all the work, though we have to write out the regressors matrix to a set of ''.1d'' files for each condition for each run.

```
>> subj = convolve_regressors_afni(subj,'conds','runs'); 

Convolving conds regressors to form conds_conv

1 2 3 4 5 6 7 8 9 10

>> summarize(subj,'objtype','regressors')

Subject 'tutorial_subj' in 'haxby8' experiment

Regressors - [nCond x nTRs]

1) conds - [ 8 x 1210]

2) conds_shifted3 - [ 8 x 1210]

3) conds_conv - [ 8 x 1210]

>> conds_conv = get_mat(subj,'regressors','conds_conv');

>> conds_conv(:,1:10)

ans =

      0      0      0      0      0      0      0      0      0      0
      0      0      0      0      0      0      0      0      0      0
      0      0      0      0      0      0      0      0      0      0
      0      0      0      0      0      0      0      0      0      0
      0      0      0      0      0      0 0.0443 0.4878 0.8622 0.9771
      0      0      0      0      0      0      0      0      0      0
      0      0      0      0      0      0      0      0      0      0
      0      0      0      0      0      0      0      0      0      0
```

In the background, this wrote your CONDS regressors into a series of ''.1d'' text files in the current directory, one for each condition and each run, and then called WAVER to create a lot more .1d files that have been convolved.

CONVOLVE\_REGRESSORS\_AFNI.M has a bunch of handy optional arguments. For instance, let's try that again. But this time, we're also going to ask it to threshold the regressors, as way of binarizing them (useful for pure 1-of-n classification). We'll also tell it to overwrite the existing .1d files heedlessly, and visualize the regressors before and after. First though, we have to get rid of the existing CONDS\_CONV regressors, to create new ones in their place.

```
subj = remove_object(subj,'regressors','conds_conv');

subj = convolve_regressors_afni(subj,'conds','runs', ...
                                'overwrite_if_exist',true, ...
                                'binarize_thresh',0.5, ...
                                'do_plot',true);
```

You should now have a new REGRESSORS object called CONDS\_CONVT, that looks pretty similar to the shifted version from above. This makes sense - shifting by 3 timepoints is pretty similar to convolving with a haemodynamic response and then thresholding...

See ''["Manual"] / Howtos / Regressors / How can I convolve my regressors with a haemodynamic response function?'' for more information.

N.B. Often in these tutorials, we may just use the 'conds' regressor out of expedience. Really though, for a real analysis, correcting for the haemodynamic response in some way is a critical step. Convolving is probably to be preferred if your classifier can deal with continuous inputs.

## Getting rid of rest ##

The original experiment contained various rest timepoints in between blocks and runs. Shifting/convolving the regressors will mean that there is (in effect) even more rest at the beginning of each run. You can see these by displaying the first 10 timepoints from the convolved regressors matrix:

```
>> conds_conv = get_mat(subj,'regressors','conds_conv'); 

>> conds_conv(:,1:10)
```

Each column is a timepoint. Each row shows the timecourse for our model of each condition. The first few timepoints are all-zeros, indicating that no conditions were active in the design, and we may want to exclude these from the rest of our analysis (depending on which methods we're using, and what our aims are).

Let's say that we want to exclude the rest timepoints from our n-minus-one feature selection and classification.

```
>> subj = create_norest_sel(subj,'conds_conv');

Created norest_sel called conds_conv_norest from conds_conv regressors

>> summarize(subj,'objtype','selector','display_groups',false);

Subject 'tutorial_subj' in 'haxby8' experiment

Selectors - [nCond x nTRs]

1) runs - [ 1 x 1210]

2-11) runs_xval * [GRP size 10] [ 1 x 1210]

12) conds_conv_norest - [ 1 x 1210]

Let's just inspect the 'conds_conv_norest' selector that was created:

>> conds_conv_norest = get_mat(subj,'selector','conds_conv_norest');

>> conds_conv

>> conds_conv_norest

... 
```

The 'conds\_conv\_norest' selector has a 1 for timepoints that have an active condition, and a 0 for rest timepoints (where no condition is at all active. This is a pretty simplistic way of treating things, since timepoints in the model with even just a tiny amount of activity in one of the conditions will be considered 'active'. You might want to create your own 'actives' selector by thresholding the convolved regressors some other way, but that's up to you.

Then, when creating the group selectors that will get used for each iteration of the n-minus-one by the feature selection and classification algorithms, this 'conds\_conv\_norest' selector will be used as the optional actives/censor vector.

```
>> subj = create_xvalid_indices(subj,'runs', ... 
               'actives_selname','conds_conv_norest', ...
               'new_selstem','runs_norest_xval'); 
```

''[Create\_xvalid\_indices.m](http://code.google.com/p/princeton-mvpa-toolbox/source/browse/trunk/core/preproc/create_xvalid_indices.m)'' will run as normal, withholding a different run each iteration for testing. However, on top of this, all of the zero timepoints in 'conds\_conv\_norest' (i.e. the rest timepoints) will be excluded entirely from the analysis. That is, they will not be used for training or testing. In effect, they won't exist as far as ''feature\_select.m'' or ''cross\_validation.m'' are concerned.

Note: we used two optional arguments in our call to ''create\_xvalid\_indices.m''. The 'actives\_selname' argument contains the 'norest' selector we just created. The second 'new\_selstem' argument determines what the name of the new group (and its group members) will be. By default, the new name would be 'runs\_xval', but you probably already have a selectors group of this name, and you probably want to distinguish these 'norest' selectors from those that did include rest. So this 'new\_selstem' argument tells ''create\_xvalid\_indices.m'' that the new selector group (and its group members) should be called 'runs\_norest\_xval'.

This way of working tends to make life simpler, since you don't actually have to delete any timepoints - you just exclude them with the selector. This means that you don't need multiple copies of your data with different numbers of timepoints included, which can be costly and complicated. The only real disadvantages are that you are still storing those unused timepoints, rather than just throwing them away, and you have to use ''create\_xvalid\_indices.m'' to create a new set of n-minus-one selectors every time you decide you want to use a different set of timepoints.

See ''["Manual"] / Howtos / Pre-classification / How can I handpick timepoints to exclude from my analysis?'' and ''How can I exclude rest timepoints from my analysis?'' for more information.


## Moving patterns to the HD ##

Managing memory in Matlab can be awkward. The pattern data objects can get pretty big, and if you're not currently using them, then there's no need to keep them in RAM all the time. The toolbox can automatically store a pattern as a .mat file on the hard disk for you, keeping track of where that file is, so that you can continue to access it transparently using ''get\_mat.m'' and ''set\_mat.m''. Think of it as a kind of poor man's virtual memory. See ''["Manual"] / Advanced / Moving patterns to the HD'' for more information. It's very easy to do:

```
>> subj = move_pattern_to_hd(subj,'epi'); 

summarize(subj,'objtype','pattern');

>> summarize(subj,'objtype','pattern','display_groups',false)

Subject 'tutorial_subj' in 'haxby8' experiment

Patterns - [ nVox x nTRs]

1) epi -   [ 577 x 1210] [HD]

2) epi_z - [ 577 x 1210]

3-12) epi_z_statmap * [GRP size 10] [ 577 x 1] 
```

Look at the end of the line describing the first pattern, 'epi'. It now has a '[HD](HD.md)' tag, showing that the pattern is being stored on the HD. We can inspect the 'epi' pattern object itself to confirm this:

```
>> epi_obj = get_object(subj,'pattern','epi') 

epi_obj =

name: 'epi'

header: [1x1 struct]

mat: []

matsize: [577 1210]

group_name: ''

derived_from: ''

created: [1x1 struct]

masked_by: 'VT_category-selective'

last_modified: '051126_1737_00'

movehd: [1x1 struct] 
```

You can see that the 'mat' field is now empty. But there's a new 'movehd' field:

```
>> epi_obj.movehd 

ans =

first_saved: '051126_1736_59'

pathfilename: 'haxby8_tutorial_subj_050831_1657_37/epi_051126_1736_59' 
```

This tells us that the matrix is stored in a file called 'haxby8\_tutorial\_subj\_050831\_1657\_37/epi\_051126\_1736\_59.mat'. [this filename includes the date and time, the filename will be different for you](Since.md). Sure enough:

```
>> ls haxby8_tutorial_subj_050831_1657_37 

. epi_051126_1736_59.mat

.. 
```

Even though the 'epi' pattern is stored on the HD, it is still accessible by the normal means:

```
>> get_mat(subj,'pattern','epi') 

Retrieving mat from haxby8_tutorial_subj_050831_1657_37/epi_051126_1736_59

ans =

Columns 1 through 6

1167 1180 1194 1208 1212 1184

1318 1349 1332  1350 1354 1341

1235 1211 1215 1228 1236 1187

774 763 760 763 774 755

1417 1425 1432 1433 1435 1427

1505 1498 1478 1497 1499 1475

1015 1026 1010 995 1004 988

1693 1696 1695 1690 1696 1687

etc. etc. etc. 
```

If you're lazy, or RAM is tight, you can tell the toolbox to just store all the current patterns to files on the hard disk.

```
subj = move_all_patterns_to_hd(subj);
```

If you do decide that you want to store a pattern back in RAM, then you can reverse the move with ''load\_pattern\_from\_hd.m'':

```
>> subj = load_pattern_from_hd(subj,'epi'); 

Loading in haxby8_tutorial_subj_050831_1657_37/epi_051126_1736_59.mat - 1098844 bytes

Loaded pattern epi from harddisk as haxby8_tutorial_subj_050831_1657_37/epi_051126_1736_59.mat 
```

The short story is that moving all your patterns to be stored on the HD will mean that the 'subj' structure takes up less RAM, and becomes more of a coat-hanger on which to hang all your data. However, the downside is that there's an overhead in loading and saving the patterns to the HD each time they're accessed.


## Voxel selection tips and tricks ##

For information on voxel selection using AFNI's GLM
(3dDeconvolve), see TutorialAfniGlm.


### Peeking voxel selection ###

Just for completeness' sake, we will briefly discuss creating a 'peeking' mask, i.e. one that chooses voxels using timepoints from the entire dataset. If you just want to create a nice brainmap, maximizing statistical power, and don't plan to use the map as the basis of a mask for classification, then this is a perfectly reasonable thing to do. It is, after all, the kernel of most univariate neuroimaging analyses.

There are two ways to do this. The first builds on everything we've done so far. It involves calling FEATURE\_SELECT.M, feeding in a single-member selector group, all of whose timepoints are marked with a 1.

This utilizes [peek\_feature\_select.m](http://code.google.com/p/princeton-mvpa-toolbox/source/browse/trunk/core/preproc/peek_feature_select.m), which works in almost the same way as the standard no-peeking [feature\_select.m](http://code.google.com/p/princeton-mvpa-toolbox/source/browse/trunk/core/preproc/feature_select.m) function, taking in almost exactly the same argument.

```
>> runs = get_mat(subj,'selector','runs'); 

>> nTimepoints = length(runs);

>> allones = ones(1,nTimepoints);

>> subj = initset_object(subj,'selector', ...
                        'allones_group_1', ...
                        allones, ...
                        'group_name','allones_group');
```

Unpacking the INITSET\_OBJECT.M call, we can see that it says to create a selector called 'allones\_group\_1', which is a member of the group 'allones\_group'. In fact, it will be the ''only'' member of that group. FEATURE\_SELECT requires the selector argument to be a group, which is why we have to do this.

Then, we can simply call FEATURE\_SELECT.M as normal, feeding in our new single-member all-1s selector group:

```
>> subj = feature_select(subj,'epi_z','conds_convt','allones_group')
```

This will create a single-member statmap group, containing the p-values resulting from running the ANOVA on all the timepoints.

The second method for running an analysis on the whole dataset is just a shortcut for the above. The
[peek\_feature\_select.m](http://code.google.com/p/princeton-mvpa-toolbox/source/browse/trunk/core/preproc/peek_feature_select.m) takes in almost the same arguments as FEATURE\_SELECT.M, except that its selector argument has to be a single object, not a group:

```
>> subj = peek_feature_select(subj,'epi_z','conds_convt','allones_1')
```

In the above call, the only difference is that we're feeding in the 'allones\_1' object, rather than the 'allones\_group' group of selectors.

Having the PEEK\_FEATURE\_SELECT.M function may seem redundant. Why not just have FEATURE\_SELECT.M take in either a group or single object as its selector? This forces the user to be very deliberate when running a peeking analysis. By enforcing this separation, we hoped to avoid accidentally feeding in a single selector, creating a single mask, and then running cross-validation multiple times with that single mask, and unwittingly generating bogus peeking results.


### Create\_pattern from mask ###

''Cross\_validation.m'' is pretty flexible - you can either feed it a single pattern with lots of different masks, or multiple patterns (each with their own masks). This latter method is often faster, since the multiple individual patterns will probably take up less space than the single big pattern with all voxels. ''Create\_pattern\_from\_mask.m'' takes a pattern and a restrictive mask, and applies the mask to the pattern to whittle down the number of voxels, creating a new pattern.

```
>> subj = create_pattern_from_mask(subj,'epi_z','3dD_200','epi_z_3dD_200');
```

This will create a group of patterns called 'epi\_z\_3dD\_200', each one of which has been masked by a different member of the '3dD\_200' mask group. Each pattern will include 200 voxels (which may or may not be the same 200). You can now move the original, full 'epi\_z' pattern to the HD, since we don't need it for now.

```
>> subj = move_pattern_to_hd(subj,'epi_z');
```


## Writing To AFNI ##

Now, let's write out one of our newly-created masks back out as a BRIK to AFNI to view. This is pretty easy to do, but it requires a sample BRIK of the same resolution/orientation/etc. Let's try writing out one of the mask objects using the intra-cranial mask BRIK as the sample BRIK:

```
>> write_to_afni(subj,'mask','3dD_200_1','wholebrain+orig');
```

If you have any trouble with this, try using a different sample BRIK, and all should be well.

## Classification tips and tricks ##

For more information on classification, see TutorialClass.


## Giving something back ##

If there's functionality that you need and want to contribute some scripts to be released as part of the toolbox that would be phenomenal and we would very much like to hear from you - you might also want to have a look at the [../progress/todo.txt to do list].