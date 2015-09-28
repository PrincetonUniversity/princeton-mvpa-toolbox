# Howtos #



### What do I do if I start getting memory errors' ###

See _[Advanced / Managing memory](ManualAdvancedMemoryManagement.md)_.


### How can I slim down the output from summarize.m ###

If you have lots of groups, each containing lots of objects, then the output from _summarize.m_ can be very long. In order to avoid this, there are a couple of ways to slim down its output.

The most obvious is to only display objects of one type. For instance, if you are only interested in _selector_ objects, you might try the optional `objtype` argument:

```
>> summarize(subj,'objtype','selector') 

Subject 'tutorial_subj' in 'haxby8' experiment

Selectors - [nCond x nTRs]

1) runs - [ 1 x 1210]

2) runs_xval_1 - [GRP size 10] [ 1 x 1210]

3) runs_xval_2 - [GRP size 10] [ 1 x 1210]

4) runs_xval_3 - [GRP size 10] [ 1 x 1210]

5) runs_xval_4 - [GRP size 10] [ 1 x 1210]

6) runs_xval_5 - [GRP size 10] [ 1 x 1210]

7) runs_xval_6 - [GRP size 10] [ 1 x 1210]

8) runs_xval_7 - [GRP size 10] [ 1 x 1210]

9) runs_xval_8 - [GRP size 10] [ 1 x 1210]

10) runs_xval_9 - [GRP size 10] [ 1 x 1210]

11) runs_xval_10 - [GRP size 10] [ 1 x 1210] 
```

If you only care which groups exist in the ''subj'' structure, and you're not too interested in the names of the individual objects contained in those groups, then you can specify that the individual members of the groups should not be displayed, e.g.

```
>> summarize(subj,'display_groups',false) 

Subject 'tutorial_subj' in 'haxby8' experiment

Patterns -  [ nVox x nTRs]

1) epi - [ 577 x 1210]

2) epi_z - [ 577 x 1210]

3-12) epi_z_statmap * [GRP size 10] [ 577 x 1]

Regressors - [nCond x nTRs]

1) conds - [ 8 x 1210]

Selectors - [nCond x nTRs]

1) runs  - [ 1 x 1210]

2-11) runs_xval * [GRP size 10] [ 1 x 1210]

Masks - [ X x Y x Z ] [ nVox]

1) VT_category-selective  - [ 64 x 64 x 40] [ 577]

2-11) epi_z_thresh * [GRP size 10] [ 64 x 64 x 40] [ V ] 
```

**Variable-size groups truncated. See help for display info.**

Conversely, setting the 'display\_groups' argument to ''true'' will ensure that all the individual members of the groups will be shown.

Often, combining the two arguments can be useful, e.g. if you want to display all the individual members of groups, but only for selectors:

```
>> summarize(subj,'display_groups',false,'objtype','selector') 

Subject 'tutorial_subj' in 'haxby8' experiment

Selectors - [nCond x nTRs]

1) runs - [ 1 x 1210]

2-11) runs_xval * [GRP size 10] [ 1 x 1210] 
```

By default, ''summarize.m'' tries to be a bit clever ' if you don't have many objects, it will display all the individual members. However, if you have quite a few, then it will concatenate all the ones that have the same sized mat field, but show you individual group members if they differ.


### How do I store an object as singles rather than doubles ###

Since the data from the scanner is often fairly noisy, it's rarely necessary to use a ''double'' type to store all the significant figures, which is the default used by Matlab. Storing the data as ''singles'' will use half the number of bytes for each value (4 rather than 8 bytes on most v7 installations).

''Patterns'' tend to be the largest objects. For these, the easiest way to use the ''single'' type is by specifying the optional 'single' argument to be ''true'' when calling ''load\_afni\_pattern.m'', e.g.

```
>> subj = load_afni_pattern(subj,'epi','mymask','mybrik+orig','single',true); 
```

There is no specific mechanism for casting existing objects of other kinds to ''singles'', but here is an example solution for casting a 'runs' selector to be of type ''single'':

```
>> runs = get_mat(subj,'selector','runs'); 

>> runs_single = single(runs);

>> >> whos runs*

Name Size Bytes Class

runs  1x1210 9680 double array

runs_single 1x1210 4840 single array

>> subj = set_mat(subj,'selector','runs',runs_single); 
```

Note: at the time of writing, some of the core functions for copying objects may not be very smart about ensuring that the new objects' matrices are of the same type as the object they are a duplicate of. Hopefully, at the time of reading, this will have been fixed. All the same, you would be wise when using matrices of ''single'' type that new objects (created with ''init\_object.m'' and ''set\_mat.m'', or with ''duplicate\_object.m'') contain matrices of the right'' ''type.


### How would I store two subjects' worth of data' ###

At this stage, we haven't agreed upon a convention for storing two subjects' worth of data at the same time. There are lots of reasons one might want to do this, e.g. training on one subject and testing on the other.

There are various approaches to consider:

1. Have two 'subj' structures, e.g. 'subj1' and 'subj2'. After all, although we always name the 'subj' structure 'subj', none of the functions care what it's actually called in your workspace. You'd initialize them something like this:

```
>> subj1 = init_subj('multi-subj_experiment','first_subj'); 

>> subj2 = init_subj('multi-subj_experiment','second_subj');

>> subj1 = load_afni_pattern(subj1,'epi','subj_brik1+orig');

>> subj2 = load_afni_pattern(subj2,'epi','subj_brik2+orig');
```

Now, each 'subj' structure will look like this:

```
>> summarize(subj1) 

Subject 'first_subj' in 'multi-subj_experiment' experiment

Patterns - [ nVox x nTRs]

1) epi - [50000 x 1000]

No regressors objects

No selector objects

No mask objects

>> summarize(subj2)

Subject 'second_subj' in 'multi-subj_experiment' experiment

Patterns - [ nVox x nTRs]

1) epi - [60000 x 1000]

No regressors objects

No selector objects

No mask objects 
```

and from that point, just use 'subj1' and 'subj2' as your variables. You'll have to write custom functions to replace ''cross\_validation.m'' that take in two 'subj' structures though.

```
2. Have a single 'subj' structure, as normal, with two epi patterns, e.g. 

>> subj = init_subj('multi-subj_experiment','both_together');

>> subj = load_afni_pattern(subj,'epi_1','subj_brik1+orig');

>> subj = load_afni_pattern(subj,'epi_2','subj_brik2+orig');

>> summarize(subj)

Subject 'both_together' in 'multi-subj_experiment' experiment

Patterns - [ nVox x nTRs]

1) epi_1 - [50000 x 1000]

2) epi_2 -  [60000 x 1000]

No regressors objects

No selector objects

No mask objects 
```

You will still need some kind of custom function that takes in two pattern names.

3. Concatenate the two patterns together to form one pattern, and create a custom selector group with 2 members, where you train on one subject's data, and test on the other, and vice versa.

Unfortunately, this requires that both subjects' data have the same number of voxels. This might be appropriate if they had been talairached or flatmapped onto a sphere of the same size. In the case above, where the patterns have different numbers of voxels, we would need a principled way of deciding which voxels to remove. For now, let's simplify and just remove the last 10,000.

Using the same subject called 'both\_together' that we created above in approach 2:

```
>> epi_1 = get_mat(subj,'pattern','epi_1'); 

>> epi_2 = get_mat(subj,'pattern','epi_2');

>> epi_2 = epi_2(1:50000,:);

>> epi_both = [epi_1 epi_2];

>> size(epi_both)

ans =

50000 2000 

>> subj = initset_object(subj,'pattern','epi_both',epi_both);

Now, we need to create custom selector objects, and make them part of the same group:

>> sel1 = ones(1,2000);

>> sel1(1001:end) = 2;

>> sel2 = ones(1,2000);

>> sel2(1:1000) = 2;

>> subj = initset_object(subj,'selector','two_subjs_xval_1',sel1,'group_name','two_subjs_xval');

>> subj = initset_object(subj,'selector','two_subjs_xval_2',sel2,'group_name','two_subjs_xval');
```

Now we're ready to call cross\_validation as normal:

```
>> [subj results] = cross_validation(subj,'epi_both','conds','two_subjs_xval_2','masks',class_args);
```

Note: in this toy example, we didn't bother to create the 'conds' regressors or the 'masks' masks or the class\_args structure, which you would obviously need to do first.

This third approach would be the easiest, since it employs existing functions. However, it's not very flexible, and it involves throwing two subjects' worth of data into a single variable, which seems like a recipe for confusion later.


### What if I don't want to use Matlab? Are there any alternatives to the MVPA toolbox? ###

At the time of writing, we are aware of 2 recent efforts to help with running multi-voxel pattern analyses:

If you like the idea of multi-voxel pattern analysis, but don't or can't use Matlab, then you may be interested in [PyMVPA](http://www.pymvpa.org/). This is a Python-based toolbox similar in spirit to our Matlab MVPA toolbox, written by Michael Hanke, Yaroslav Halchenko, Per Sederberg and the rest of the Debian Experimental Psychology crew.

Jeffery Prescott and Stephen La''''''Conte's [3dsvm](http://afni.nimh.nih.gov/pub/dist/doc/program_help/3dsvm.html) is a plugin that allows you to run support vector machine analyses from within AFNI.

If you know of any others, [let us know](mailto:mvpa-toolbox@googlegroups.com) and we'll update this page.