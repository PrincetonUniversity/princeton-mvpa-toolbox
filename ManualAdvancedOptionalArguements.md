# Advanced Manual #

## Optional arguments ##

All of the functions in the toolbox use the same conventions for optional arguments, since they all rely on _[propval.m](http://code.google.com/p/princeton-mvpa-toolbox/source/browse/trunk/core/util/propval.m)_. This is a standalone function that makes it very easy to specify what optional arguments a function should accept, in any order, what default arguments it should use if they're not supplied, and with lots of error-checking and warning.

Optional arguments must be supplied in property/value pairs, e.g.

```
>> summarize(subj,'display_groups',false) 

Here, the property being specified is 'display_groups' and the value being specified is _false_. Multiple optional arguments can be specified at once, and in any order, e.g.

>> summarize(subj,'display_groups',false,'objtype','selector')

or:

>> summarize(subj,'objtype','selector','display_groups',false)
```

In this case, the property/value pairings are as follows:

|  _Property_ |  _Value_ |
|:------------|:---------|
|  display\_groups |  false   |
|  objtype    |  'selector' |


Properties are always strings, and always come first in the pair. Values can be strings, or any other type, and always come second.

By the way, for more information on the [summarize.m](http://code.google.com/p/princeton-mvpa-toolbox/source/browse/trunk/core/subj/summarize.m) function, see also: [Viewing the subj structure](ManualDataStructures#Viewing_the_subj_structure_and_objects_within_it.md) and [How can I slim down the output from summarize.m](HowtosMisc#How_can_I_slim_down_the_output_from_summarize.m.md).

In the help for a function, the triple-dot at the end of the function declaration denotes that it takes optional arguments, e.g.

```
>> help summarize 

[] = summarize(subj,...)

Below, the help says:

DISPLAY_GROUPS (optional, default = blah) ' blah blah

OBJTYPE (optional, default = blah) ' blah blah
```

In this way, all the allowed optional argument properties will be listed, along with their default values (if they are left unspecified), and what terrible things will be wrought by each.

This is a powerful and flexible mechanism, since it allows us to keep basic function declarations simple if you want to use the defaults, but doesn't restrict the user if they do want to specify niceties.

There is one further way in which optional arguments can be supplied. If calling a function with lots of optional arguments, it can be a pain to specify them all each time. In this case, you can bundle them all together in a structure, and just feed that in. Propval.m will understand and deconstruct the structure in exactly the same way as before, e.g.

```
>> summ_args.display_groups = false; 

>> summ_args.objtype = 'selector';

>> summarize(subj,summ_args)
```

See the help for [propval.m](http://code.google.com/p/princeton-mvpa-toolbox/source/browse/trunk/core/util/propval.m) for more information.

Note: there is one exception - [summarize.m](http://code.google.com/p/princeton-mvpa-toolbox/source/browse/trunk/core/subj/summarize.m) has a special single optional boolean argument that determines whether or not to display all the members of a group. This is for the user's convenience, since _summarize.m_ gets called so much, but may be deprecated in future versions.