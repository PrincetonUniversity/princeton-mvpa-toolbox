# Howtos #

## Exporting ##


### Can the toolbox help me write BRIKs ###

Even if you're not using most of the toolbox's functionality, it provides wrappers for Ziad Saad's afni\_matlab library that might make importing/exporting easier.

If all you want to do is write out a matrix from Matlab into a BRIK, then [write\_to\_afni.m](http://code.google.com/p/princeton-mvpa-toolbox/source/browse/trunk/core/io/write_to_afni.m) or [zeroify\_write\_afni.m](http://code.google.com/p/princeton-mvpa-toolbox/source/browse/trunk/core/io/zeroify_write_afni.m) will probably help, as described in greater detail in their own help and in [Howtos / Exporting / ](HowtosExporting.md).

Both of them use an existing sample BRIK of the right resolution and orientation to help create the header the structure. The main difference is that [write\_to\_afni.m](http://code.google.com/p/princeton-mvpa-toolbox/source/browse/trunk/core/io/write_to_afni.m) takes in a complete `subj` structure and pattern/mask name as arguments, while zeroify\_write\_afni.m takes the matrix variable itself directly.

These can substantially help you if you're trying to write out BRIKs, since you don't have to worry about headers or anything like that. Write\_to\_afni.m is particularly useful if you want to write out an nVoxels x nTimepoints matrix, since it will also figure out where in the brain the voxels in your pattern are.

See also: [Howtos / Patterns / Can the toolbox help me load BRIKs](HowtosPattern#Can_the_toolbox_help_me_load_BRIKs.md).


### Sometimes when using write\_to\_afni.m, I get this message: Problem using spoofing write method - trying again with zeroifying - you can safely ignore this message and the following error stack ###

_[Write\_to\_afni.m](http://code.google.com/p/princeton-mvpa-toolbox/source/browse/trunk/core/io/write_to_afni.m)_ calls _WriteBrik.m_ (from Ziad Saad's afni\_matlab library) to do all the hard work. The complicated part comes when figuring out what should go in the header of the BRIK. There are two ways we've come up with to do this:

1. The _spoofing_ method

Try and construct a header structure from scratch, based on the parameters and information we have about the pattern. This requires you to also provide the name of an existing BRIK in the same resolution/orientation etc., from which we can borrow any information we don't have. Then, we call _WriteBrik.m_ to write this out as a BRIK.

_WriteBrik.m_ calls _[CheckBrikHEAD.m](http://code.google.com/p/princeton-mvpa-toolbox/source/browse/trunk/afni_matlab/CheckBrikHEAD.m)_ to ensure that all is well with the header information. More often than not, there is a problem. We are looking into ways to improve this functionality. You can turn off the extra checking in _[CheckBrikHEAD.m](http://code.google.com/p/princeton-mvpa-toolbox/source/browse/trunk/afni_matlab/CheckBrikHEAD.m)_, but this seems like a bad idea, since you'll potentially cause yourself problems when AFNI tries to read the file later.

2. The _zeroifying_ method

If that first method fails, then it tries a second, more robust but less elegant tactic. It takes the sample BRIK, duplicates it, reads it in using BrikLoad (including the header information), overwrites the loaded matrix with the matrix to be written out, and then uses WriteBrik straight away on the matrix and header information.

This works every time, since it's employing header information from a legitimate BRIK file. However, it involves creating a dummy all-zeros BRIK, and a lot of extra duplicating, loading in and writing out. Also, at the time of writing, much of the functionality allowed by the spoofing method hasn't been implemented for this zeroifying method.

The funny error message that you got with [write\_to\_afni.m](http://code.google.com/p/princeton-mvpa-toolbox/source/browse/trunk/core/io/write_to_afni.m) should now make sense. It realised that the first spoofing method failed, and so it's trying the second zeroifying method now.

See the _[write\_to\_afni.m](http://code.google.com/p/princeton-mvpa-toolbox/source/browse/trunk/core/io/write_to_afni.m)_ and _[zeroify\_write\_afni.m](http://code.google.com/p/princeton-mvpa-toolbox/source/browse/trunk/core/io/zeroify_write_afni.m)_ help for more information, and also _Howtos / Exporting / [Can the toolbox help me write BRIKs](HowtosExporting#Can_the_toolbox_help_me_write_BRIKs.md)_.


### What if I get an out of memory error when trying to write a BRIK ###

Chances are, you're trying to write a functional BRIK with lots of timepoints. Use the 'runs' optional argument to split the data up into multiple BRIK files by run.