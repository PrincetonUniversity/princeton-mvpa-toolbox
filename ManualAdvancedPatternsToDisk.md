# Advanced Manual #

## Moving patterns to the hard disk ##

The [move\_pattern\_to\_hd.m](http://code.google.com/p/princeton-mvpa-toolbox/source/browse/trunk/core/subj/move_pattern_to_hd.m) and its companion, [load\_pattern\_from\_hd.m](http://code.google.com/p/princeton-mvpa-toolbox/source/browse/trunk/core/io/load_pattern_from_hd.m) are designed to free up RAM without throwing away information. They allow you to move the matrix contents of a particular object out to a file, while allowing you to access that data using the standard _get/set\_object_ scripts entirely transparently. This is one of the side-advantages of using the accessor scripts as a layer of abstraction between the toolbox's data structures and you, the user.

If you're having trouble with memory, we recommend that you choose a couple of large pattern objects that you're not using and use move\_pattern\_to\_hd.m on them to free up RAM. Of course, access times for data stored on the hard disk are much, much slower than for data stored in RAM. For this reason, the data can be moved back into RAM (removing any traces from the hard disk) with [load\_pattern\_from\_hd.m](http://code.google.com/p/princeton-mvpa-toolbox/source/browse/trunk/core/io/load_pattern_from_hd.m).

In the future, we hope to take advantage of Matlab's memory-mapping functionality or investigate other file formats that will allow more efficient random-access than the .mat format, which requires the entire matrix to be loaded in before it can be accessed. Any advice or support [would be appreciated](ContactDetails.md).

It is worth noting that this functionality only exists for _patterns_, since they take up so much more space than any of the other data types.

See [tutorial\_hard](http://code.google.com/p/princeton-mvpa-toolbox/source/browse/trunk/core/tutorial_hard.m) / Moving patterns to the HD for a walkthrough of how to do this.