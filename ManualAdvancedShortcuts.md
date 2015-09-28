# Advanced Manual #

## Handy shortcuts ##

We've tried to add some minor labor-saving devices to make using the toolbox easier.


### Getting the latest object names ###

Much of the time, you'll want to look at or use the most recently-created pattern, or run or regressors or mask. Sometimes, it can be a pain to remember or type long object names, and sometimes when writing functions, you may not know in advance what the latest names will be.

To make this easier, the toolbox keeps track of the latest object of each type that was initialized as subj.p, .r, .s and .m. This way, you could type:

```
>> get_object(subj,'pattern',subj.p) 

as a bit of a shorthand. 
```

Note: this is one of those handy labour-saving devices that might prove a terrible idea if used carelessly. For instance, be careful after creating a group, since it's unlikely that you'll want to specifically access the last item in that group.

Note: We deliberately decided not to have the remove functions alter the subj.x shortcuts when removing the highest-numbered mat or object of its type. This way, if you forget to update them yourself, you'll get an error. If we were to automatically set them to the next highest-numbered item, you might not notice and end up with a subtil and devilish bug.

If you have ideas for other ways to speed up frequently-performed tasks or minimize how much typing users have to do, we'd be happy to [hear from you](ContactDetails.md).


### Getting the mat immediately from a duplicated object ###

Often, you'll find yourself doing the following:

1. duplicating an object

2. getting the _mat_ from the new object

3. modifying it

4. setting it back into the object.

To reduce this down by one step, it's worth noting that the [duplicate\_object.m](http://code.google.com/p/princeton-mvpa-toolbox/source/browse/trunk/core/subj/duplicate_object.m) function will return the duplicated object's _mat_ as its second argument, allowing you to combine the first two steps in one line:

```
>> [subj duplicated_mat] = duplicate_obj(subj,objtype,old_objname,new_objname);
```