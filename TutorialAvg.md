# Tutorial on averaging #

See also:

http://groups.google.com/group/mvpa-toolbox/browse_thread/thread/a3baf7b35bb33f6f#


---


This tutorial discusses averaging multiple timepoints together. For instance, you might want to compress a sequential series of images into one image that summarizes a single trial. This might average out some of the noise over the course of the trial, improving classification performance. Since we often care more about the classifier's response to the trial as a whole rather than at each timepoint, this may be a sensible move.

The toolbox includes a handy function called [average\_object.m](http://code.google.com/p/princeton-mvpa-toolbox/source/browse/trunk/core/preproc/average_object.m) that's designed for this very purpose. It needs to be told which timepoints to average together though, so it takes in a 'blocklabels' selector as an argument, which groups timepoints which you want to average together by assigning them the same integer label.

Let's consider a simple example. If your runs selector looks like this (2 runs, with 4 timepoints per run):

```
1 1 1 1 2 2 2 2
```

and your regressors look like this (2 conditions):

```
1 1 0 0 1 1 0 0
0 0 1 1 0 0 1 1
```

then the blocklabels might look like this:

```
1 1 2 2 3 3 4 4
```

In this case, each trial lasts for exactly 2 timepoints and there are 2 trials per run, with no rest. If you feed in this blocklabels selector into average\_object.m, then it will cause each 2-timepoint trial to get averaged together.

You could create that selector yourself, and for complex cases, you will probably have to. But for simple cases, you may find that [create\_blocklabels.m](http://code.google.com/p/princeton-mvpa-toolbox/source/browse/trunk/core/preproc/create_blocklabels.m) will do the job for you. It assigns a unique blocklabel number to all the timepoints from a given condition in a run. If each condition shows up in a single block per run, this is probably exactly what you want.

Now, you can just pass in the selector created by  `create_blocklabels.m` (or a selector of your own devising) into `average_object.m`, along with the object you want to average, and it should do the rest. This two-step process makes it easy to do the most straightforward things, and as easy as possible to do more complicated things.

Let's consider an example, using the tutorial dataset. Make sure you've run tutorial\_easy.m first.

```
>> subj = create_blocklabels(subj,'conds','runs');
Excluding timepoints from blocklabels
Warning: Rest will be excluded
> In create_blocklabels at 74
Created blocklabels with 80 unique blocks
```

We can visualize what the blocklabels look like:

```
>> blocklabels = get_mat(subj,'selector','blocklabels');
>> imagesc(blocklabels)
```

or just print them to the screen:

```
>> blocklabels
```

As you can see, `create_blocklabels.m` has assigned values from 0 to 80 to every timepoint:

```
>> min(blocklabels)

ans =

     0

>> max(blocklabels)

ans =

    80
```

This fits - there are 8 conditions, each of which shows up once per run (10 runs), making a total of 80 blocks, each of which has a unique (and more or less meaningless) label. The '0' labels are reserved for rest timepoints, which will be ignored by `average_object.m`.

Now, we can pass this blocklabels selector into `average_object.m`, and it'll do all the hard work for us:

```
>> subj = average_object(subj,'pattern','epi_z','blocklabels');
>> subj = average_object(subj,'regressors','conds','blocklabels');
>> subj = average_object(subj,'selector','runs','blocklabels');   
>> summ
 
Subject 'tutorial_subj' in 'haxby8' experiment
 
Patterns -                                              [ nVox x nTRs]
    1) epi                            -                 [  577 x 1210]     
    2) epi_z                          -                 [  577 x 1210]     
 3-12) epi_z_anova                    *   [GRP size 10] [  577 x    1]      
   13) epi_z_avg                      -                 [  577 x   80]     

Regressors -                                            [nCond x nTRs]
    1) conds                          -                 [    8 x 1210]
    2) conds_avg                      -                 [    8 x   80]

Selectors -                                             [nCond x nTRs]
    1) runs                           -                 [    1 x 1210]
 2-11) runs_xval                      *   [GRP size 10] [    1 x 1210]      
   12) blocklabels                    -                 [    1 x 1210]
   13) runs_avg                       -                 [    1 x   80]

Masks -                                                 [ X  x  Y  x  Z ] [ nVox]
    1) VT_category-selective          -                 [ 64 x  64 x  40] [  577]
 2-11) epi_z_thresh0.05               *   [GRP size 10] [ 64 x  64 x  40] [  V  ]
* Variable-size groups truncated. See help for display info.
```

Note the new _**avg objects.**

Note that you only needed to call create\_blocklabels.m once. Then you can keep feeding that same blocklabels selector in each time as you call average\_object.m on your patterns, your regressors and your runs. This guarantees that the same averaging is being applied to each._

If you want to average in a different way, just create a blocklabels selector of your own (which could be called anything), and pass that in as the argument to `average_object.m`.

Finally, the new objects know how they were created, so you can remind yourself later:

```
>> epi_z_avg = get_object(subj,'pattern','epi_z_avg') 

epi_z_avg = 

             name: 'epi_z_avg'
           header: [1x1 struct]
              mat: [577x80 double]
          matsize: [577 80]
       group_name: ''
     derived_from: 'epi_z'
          created: [1x1 struct]
        masked_by: 'VT_category-selective'
    last_modified: '080818_1638_16'

>> epi_z_avg.created     

ans = 

           datetime: '080818_1638_16'
            dbstack: [3x1 struct]
           function: 'average_object'
               args: [1x1 struct]
       use_mvpa_ver: 0
            patname: 'epi'
            selname: 'runs'
    actives_selname: ''
        labels_name: 'blocklabels'
```