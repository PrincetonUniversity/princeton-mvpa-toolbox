# Advanced Manual #

## Managing memory ##

The toolbox has a packrat mentality ' it hoards every version of the data that it processes. For instance, it keeps separate patterns for before and after zscoring with zscore\_runs.m. This makes sense, because it makes it easy to take a step back in the analysis path and re-run things with slightly different parameters. However, it can eventually clog up your RAM, especially with large patterns.

For this reason, if you know that you plan to apply a mask to your data (e.g. to exclude voxels from outside the cranium), then use that mask as the argument to [load\_afni\_pattern.m](http://code.google.com/p/princeton-mvpa-toolbox/source/browse/trunk/core/io/load_afni_pattern.m) when loading in the data in the first place. Unfortunately, the core [BrikLoad.m](http://code.google.com/p/princeton-mvpa-toolbox/source/browse/trunk/afni_matlab/BrikLoad.m) function loads in the entire volume first and then applies the mask, but if you're loading in separate runs at a time, then this shouldn't be a huge problem.

Since the data from the scanner is often fairly noisy, it's rarely necessary to use a _double_ type to store all the significant figures, which is the default used by Matlab. See [How do I use singles rather than doubles](HowtosPattern#How_do_I_store_a_pattern_as_singles_rather_than_doubles.md) for further information about this.

Another useful tactic is to store large patterns that you're not using at the moment on the hard disk, rather than in RAM. The toolbox makes this easy to do, using [move\_pattern\_to\_hd.m](http://code.google.com/p/princeton-mvpa-toolbox/source/browse/trunk/core/subj/move_pattern_to_hd.m). See tutorial\_hard.htm / Moving patterns to the HD for more information.

Finally, you can always just [remove the object](ManualAdvancedRemovingObjects.md).

See also:

## Amount of required RAM ##

In order to do anything with a Matlab matrix, you really need enough RAM to store it twice. Removing or adding a column to it, or modifying it within a function, require a duplication of that matrix. We have endeavored to ensure that the toolbox never requires you to have more RAM than needed to hold a single duplicate of your data. Some of the toolbox's internal accessor functions (such as the set/get\_object functions, and the init\_new\_object functions) may look incredibly inefficient, since it seems as though they are making multiple copies of entire objects or even entire cell arrays of objects and passing them up and down functions. The advantage of this coding style is that all of the accessor logic for the 4 data types is in one place. Fortunately, even though Matlab passes by value and doesn't explicitly allow the use of pointers, it appears to implicitly use pointers in a clever way to ensure that it only actually makes a copy of an argument when passing it into a function if the contents of that argument get modified.

Having experimented with different ways of storing and passing objects between functions, we don't think the toolbox could manage its variables much more efficiently, short of shunning functions entirely. If you have any better ideas, or believe this explanation to be in error, we would be very interested to [hear from you](ContactDetails.md).

Finally, don't forget that you can [store your patterns on the hard disk rather than in RAM](ManualAdvancedMemoryManagement#Managing_memory.md) when they're not being used.