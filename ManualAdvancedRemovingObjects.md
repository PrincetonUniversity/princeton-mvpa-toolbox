# Advanced Manual #

## Removing objects ##

There are two ways in which you can remove objects:

  1. [Remove\_mat.m](http://code.google.com/p/princeton-mvpa-toolbox/source/browse/trunk/core/subj/remove_mat.m) will set the object's _mat_ to empty. Since this is where each object's main matrix is stored, this is probably taking up most of the room occupied by the object. This is usually sufficient, and has the advantage that it leaves the surrounding _name_ and _header_ information intact, in case other objects want to reference it, and doesn't renumber the cells.
  1. If you really want to, you can remove the entire cell for the object, by passing in 'erase' as the optional argument to [remove\_object.m](http://code.google.com/p/princeton-mvpa-toolbox/source/browse/trunk/core/subj/remove_object.m).

Since _patterns_ tend to be the biggest memory hogs, you can also just transparently [shift the \_pattern\_ to the hard disk](HowtosExporting.md), which frees up your RAM without throwing away data that might be useful later on. See Advanced / [memory](ManualAdvancedMemoryManagement.md) for more solutions.