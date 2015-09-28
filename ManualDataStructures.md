# Data structures #



All the basic information we use for classification is contained in a single _subj_ structure - one per subject. The _subj_ structure itself is really just four cell arrays, each containing multiple objects. An object can be one of four main data types [patterns](ManualDataStructures#Patterns.md), [regressors](ManualDataStructures#Regressors.md), [selectors](ManualDataStructures#Selectors.md) and [masks](ManualDataStructures#Masks.md). Each object is stored as a single cell in one of the 4 _subj_ cell arrays. For instance, a single regressors object is a cell in subj.regressors{}.

See [Subj Structure](ManualDataStructures#The_Subj_Structure.md) for more details.


## Patterns ##



This is where the data from the scanner gets stored, which could take many forms. It might start as raw voxel values, in which case the dimensions would be voxels by timepoints. However, it can also be used to store beta weights, wavelet coefficients, PCA components etc.

Later, the _patterns_ will be used to generate the training data (which the classifier learns from) and testing data (which it's tested on).

There is no information about where in the brain a particular voxel/feature is located  each _pattern_ has an associated _[mask](ManualDataStructures#Masks.md)_ which contains the information about its contents' locations.

Statmaps and beta weights from GLMs and other statistical procedures are also stored as patterns, although these often do not have time as a second dimension.


## Regressors ##

For our purposes, the term **regressors** refers to a set of
values for each timepoint that denote the extent to which
each condition is active.

[If it helps you to think of these in terms of a standard
neuroimaging analysis, these are the counterparts of the
condition labels in your X matrix from which you predict
your voxel values.]

[If it helps you to think in terms of machine learning,
these are the mental state labels that we're trying
to predict from our brain state data.]

Each condition gets its own row, and each timepoint gets its
own column. In a simple 1-of-n design, the active
condition-row for a given timepoint-column is marked with a
'1', and all the other conditions are marked with
'0's. You'd have a 2D matrix with a single '1' in each
column, corresponding to the active condition for that
timepoint, e.g. 'looking at a face' vs 'looking at a house'.

N.B. The regressors matrix can contain real positive or
negative numbers, indicating that a condition is active to
some degree.

Consider this example set of _regressors_ with 3
conditions and 7 timepoints:

```
1 1 0 0 0 0 0
0 0 1 1 0 0 0
0 0 0 0 1 1 0
```

In this case, the first couple of TRs belong to condition 1, then t3 and t4 belong to condition 2, and t5 and t6 belong to condition 3. The last timepoint has no active conditions, i.e. it's rest.

This _regressors_ matrix is later fed into the classifier as the supervised labels that tell it what kind of brain state the person is in.

We tend to code rest timepoints as a column of zeros, but there might sometimes be good reasons to assign rest to have its own condition-row.

In this simple example, there is just a single '1' on each row signalling one active condition at each timepoint. However, there is nothing precluding multiple conditions being active, to greater or lesser degrees. Indeed, we recommend convolving the _regressors_ with a hemodynamic response function which will lead to non-binary regressors with some timepoints having than one condition active at the same time (see TutorialAdv).


## Selectors ##

Think of the _selectors_ row-vector as labelling each timepoint with a tag or type of some kind. Selector values must be positive integers.

For instance, a selector might label timepoints as `train` vs `test`. Or as `exclude` vs `include`. Or `run1` vs `run2` vs `run3` vs `run4` etc.


## Masks ##

A _mask_ is usually a single boolean 3D matrix the size of the original brain volume with ones showing where voxels will be kept, and zeros showing voxels that will be excluded.

A _mask_ might be defined anatomically (e.g. prefrontal cortex) or functionally by thresholding a [statmap](Glossary#statmap.md), or really any other way you choose that will yield a 3D boolean matrix of the right dimensions.

This is also where the information about the locations of the features (e.g. voxels) in a ''pattern'' is encoded. Every _pattern_ has a `masked_by` field which points to a _mask_ with the same number of active voxels, showing where in the 3D volume those _patterns_ voxels came from.

To turn the mask into a linear index of voxels that refers
to a pattern, just call the Matlab `find` command on the
_mask_.

To create a (voxels x 3) list of xyz coordinates, just call the Matlab `ind2sub` command on the _mask_. Update: v0.9 and above will include a handy [get\_coords\_from\_mask.m](http://code.google.com/p/princeton-mvpa-toolbox/source/browse/trunk/core/subj/get_coords_from_mask.m) function to do this for you.

## Chronology ##

Notice that the first three data types have time as the 2nd
dimension (columns), but _masks_ don't incorporate time at
all.

All of the scripts assume that the _patterns_,
_regressors_ and _selectors_ will be stored in
chronological order. Shuffling the temporal order (i.e. the
2nd dimension) in some way is almost certainly going to
wreak havoc with things.

Also, we strongly recommend that you don't throw away
timepoints if you can avoid it. Pretty much all the toolbox
functions have optional arguments that allow you to feed in
a boolean `actives` selector with which you can filter out
timepoints you don't care about. This will make your life
much easier in the long run, because then you'll always be
indexing into matrices with the same number of columns.

## The **Subj** Structure ##

### The innards of the _subj_ structure ###

All of the data types discussed above are stored as cell arrays in the main _subj_ structure. Each _subj_ variable is a Matlab struct containing everything that relates to a single subject (up to the point of classification). A sample _subj_ might look like this, if displayed from the Matlab terminal:

```
>> subj 

subj = 

 regressors: {[1x1 struct]}

 selectors: {[1x1 struct]}

 patterns: {[1x1 struct]}

 masks: {[1x1 struct]}

 header: [1x1 struct]

 p: 'raw'

 m: 'wholebrain'

 r: 'binaries'

 s: 'runs'` 
```

Let's just pay attention to the first four fields for now.

Storing the data types as cell arrays within the subj
structure allows us to store multiple _patterns_, multiple
_selectors_, multiple and multiple _masks_ at the same
time. As we will see, this is key to the way the toolbox is
intended to work.

This display of the _subj_ structure is somewhat spare. We
recommend using the [summarize.m](http://code.google.com/p/princeton-mvpa-toolbox/source/browse/trunk/core/subj/summarize.m) function (see [Viewing the \_subj\_ structure](ManualDataStructures#Viewing_the_subj_structure_and_objects_within_it.md)) instead.

All four data types have a stereotyped internal
organization. Let us examine a sample _regressors_ object:

```
`>> subj.regressors{1}  

ans = 

 name: 'afni1d'

 derived_from: ''

 header: [1x1 struct]

 mat: [3x100 double]

 group_name: '' 
```

All objects (that is, all _patterns_, _regressors_,
_selectors_ and _masks_) have these required fields:

**name** - this is the identifier that is used to refer to
that object. Objects of different types can have the same
name, but there can only be one _regressors_ object called
`afni1d`.

**mat** - this is where the actual matrix for the object is
stored. All 4 data types have a mat field, though the
dimensions will vary (as described in their respective
sections).

**header** - this contains book-keeping information
describing how the object was created that might be useful
for the user (see [Book-keeping](ManualDataStructures#Book-keeping_and_the_headers.md))

**derived\_from** - when an object is created by duplicating
another object, the parent object is stored here

**group\_name** - there are various instances where it makes
sense to treat multiple objects as members of a group, such
as the multiple selectors that are created for each
iteration of an n-minus-one cross-validation
classification. Each group has a name, that can be used to
find all its constituent members. The
[find\_group.m](http://code.google.com/p/princeton-mvpa-toolbox/source/browse/trunk/core/subj/find_group.m) is an auxiliary
function that returns the names of groupmembers as a cell
array.

**created** - this contains information about how the object
was created, e.g. the date and time, the name of the
function that created it, what arguments were fed to that
function at the time etc. This makes it easy to keep track
of multiple analysis paths in the same ''subj'' at once by
tracing the creation history of a given object back, via the
arguments fed to the function that created it.

There is a sense in which the patterns, regressors and
selectors could be represented as the same type, since they
are all matrices with time as the second dimension. We made
a deliberate decision to treat them as different types to
reflect their different conceptual roles in the analysis.

We have considered adding statmap as a new data type, as
well as perhaps something for behavior, but no changes of
this nature are planned for the foreseeable future.


### Accessing the _subj_ structure and objects within it ###

The pre-classification steps involved with fMRI data can
quickly become labyrinthine. Keeping track of what has been
done to the data, and trying out different analysis paths
can easily lead to innumerable versions of your data strewn
around your workspace and hard disk. We have tried to make
the toolbox do as much of this book-keeping as
possible. It's designed so that you access all of the
objects by name alone, using a collection of _accessor_
scripts rather than directly addressing the _subj_
structure. This is standard practice in object oriented
programming, but Matlab's syntax makes it a little
cumbersome to get to grips with initially.

Imagine you have lots of versions of your regressors stored. To access the first set, called `afni1d`, you could type:

```
>> myregs = subj.regressors{1}.mat
```

to access the contents of that regressors matrix. However, you _should_ use:
```
>> myregs = get_mat(subj,'regressors','afni1d')
```

This will automatically return the matrix of the _regressors_ object called 'afni1d'. Correspondingly, if you want to modify that _regressors_ matrix, e.g. by setting its first TR to rest, then you would do the following:

```
>> newmat = get_mat(subj,'regressors','afni1d'); 

>> newmat(:,1) = 0;`

>> subj = set_mat(subj,'regressors','afni1d',newmat);
```

If this strikes you as an inefficient use of memory, then see [this discussion](ManualAdvancedMemoryManagement.md) for why this isn't really a problem.

If you want to access a particular sub-field of an object, then use the _get/set\_objfield_ pair. For instance, if you want to change the 'derived\_from' field of the 'afni1d' regressors object to 'blahblah':

```
>> subj = set_objfield(subj,'regressors','afni1d','derived_from','blahblah');
```

This means that you never need to keep track of the number of an object. If you want to distinguish your raw data and your zscored data then just give them different and descriptive names, and just address them like that.

There are also _get/set\_objsubfield_ functions, but nothing for sub-subfields.

There is also a slightly different route you can take to access your objects that gives you more flexibility (but less error-checking), by retrieving the entire object (including the mat and other fields), e.g.:

```
>> obj = get_object(subj,'regressors',conds') 

obj =


 name: 'conds'

 header: [1x1 struct]

 mat: [8x1210 double]

 matsize: [8 1210]

 group_name: ''

 derived_from: ''

 created: [1x1 struct]

 condnames: []


>> obj.myfield = 'blahblah';


obj =


 name: 'conds'

 header: [1x1 struct]

 mat: [8x1210 double]

 matsize: [8 1210]

 group_name: ''

 derived_from: ''

 created: [1x1 struct]

 condnames: []

 myfield: 'blahblah'


>> subj = set_object (subj,'regressors','conds',obj);
```

There are various accessor scripts that you can use to get at the components of the _subj_ structure, many of which are listed below:

[init\_object](http://code.google.com/p/princeton-mvpa-toolbox/source/browse/trunk/core/subj/init_object.m) to create an object

[duplicate\_object](http://code.google.com/p/princeton-mvpa-toolbox/source/browse/trunk/core/subj/duplicate_object.m) ' calls init\_object, then copies across the mat from the source object and sets the derived\_from field in the new object to reflect its origins

[get](http://code.google.com/p/princeton-mvpa-toolbox/source/browse/trunk/core/subj/get_mat.m)/[set\_mat](http://code.google.com/p/princeton-mvpa-toolbox/source/browse/trunk/core/subj/set_mat.m) ' to access the ''mat'' matrix containing your data stored in an object

[initset\_object](http://code.google.com/p/princeton-mvpa-toolbox/source/browse/trunk/core/subj/initset_object.m) ' for lazy people. Calls init\_object and set\_mat in one fell swoop

[get](http://code.google.com/p/princeton-mvpa-toolbox/source/browse/trunk/core/subj/get_object.m)/[set\_object](http://code.google.com/p/princeton-mvpa-toolbox/source/browse/trunk/core/subj/set_object.m) ' to access the entire object (including the _mat_ matrix)

[get](http://code.google.com/p/princeton-mvpa-toolbox/source/browse/trunk/core/subj/get_objfield.m)/[set\_objfield](http://code.google.com/p/princeton-mvpa-toolbox/source/browse/trunk/core/subj/set_objfield.m) ' to access a field inside the object, such as the 'derived\_from' or 'group\_name' fields

[get](http://code.google.com/p/princeton-mvpa-toolbox/source/browse/trunk/core/subj/get_objsubfield.m)/[set\_objsubfield](http://code.google.com/p/princeton-mvpa-toolbox/source/browse/trunk/core/subj/set_objsubfield.m) ' to access field.subfield in the object. for subsubfields, use get\_object, modify the field manually, and then set\_object

[rename\_object](http://code.google.com/p/princeton-mvpa-toolbox/source/browse/trunk/core/subj/rename_object.m)

[rename\_group](http://code.google.com/p/princeton-mvpa-toolbox/source/browse/trunk/core/subj/rename_group.m) ' Change the group\_name for all the objects in a particular group. Doesn't affect their individual names

[remove\_mat](http://code.google.com/p/princeton-mvpa-toolbox/source/browse/trunk/core/subj/remove_mat.m) ' set the _mat_ to be empty

[remove\_object](http://code.google.com/p/princeton-mvpa-toolbox/source/browse/trunk/core/subj/remove_object.m) ' remove the object entirely from its cell array

[remove\_group](http://code.google.com/p/princeton-mvpa-toolbox/source/browse/trunk/core/subj/remove_group.m) ' calls remove\_object for all members of the group

[add\_created](http://code.google.com/p/princeton-mvpa-toolbox/source/browse/trunk/core/subj/add_created.m) ' easy way to document where an object came from

[add\_history](http://code.google.com/p/princeton-mvpa-toolbox/source/browse/trunk/core/subj/add_history.m) ' easy way to add free text notes to an object

[exist\_object](http://code.google.com/p/princeton-mvpa-toolbox/source/browse/trunk/core/subj/exist_object.m) ' returns true if an object of that name exists

[exist\_group](http://code.google.com/p/princeton-mvpa-toolbox/source/browse/trunk/core/subj/exist_object.m) ' returns true if there any objects who are members of a group

[exist\_objfield](http://code.google.com/p/princeton-mvpa-toolbox/source/browse/trunk/core/subj/exist_objfield.m)

[exist\_objsubfield](http://code.google.com/p/princeton-mvpa-toolbox/source/browse/trunk/core/subj/exist_objsubfield.m)

[get\_name](http://code.google.com/p/princeton-mvpa-toolbox/source/browse/trunk/core/subj/get_name.m) ' get the name of an object if all you know is its number. you shouldn't really ever need to use this

[get\_number](http://code.google.com/p/princeton-mvpa-toolbox/source/browse/trunk/core/subj/get_number.m) ' get the number of an object if you know its name. you shouldn't really ever need to use this either

[get](http://code.google.com/p/princeton-mvpa-toolbox/source/browse/trunk/core/subj/get_type.m)/[set\_type](http://code.google.com/p/princeton-mvpa-toolbox/source/browse/trunk/core/subj/set_type.m) ' get the cell array containing all the objects of a particular type. You should really ever need to use this either

Of course, you can always access the _subj_ structure directly, and we can't stop you, but doing so could cause unforeseen problems (see [Accessing the \_subj\_ structure directly](ManualAdvancedSubjStructureDirectAccess.md)). Adding a layer of abstraction with the accessor scripts allows us to do lots of error-checking on your behalf, and occasionally facilitates some useful tricks (e.g. [transparently storing the data on the hard disk](ManualAdvancedPatternsToDisk.md)).


### Viewing the _subj_ structure and objects within it ###

Because the output from typing `subj` at the Matlab prompt is not very informative, the _summarize.m_ function is intended to provide a more useful readout of your data.

```
>> summarize(subj) 

Subject 'TryToTakeOverTheWorld' in 'fred' experiment`

Patterns - [ nVox x nTRs]

 1) raw  - [50000 x 100] 

Regressors - [nCond x nTRs]

 1) afni1d - [ 3 x 100]


Selectors - [nCond x nTRs]

 1) runs_all_TRs - [ 1 x 100]

Masks - [ X x Y x Z ] [ nVox]

 1) wholebrain - [ 64 x 64 x 34] [ 0]

>> 
```

This shows that we only have one object of each type, what their names are and the sizes of their internal matrices.

If you have lots of groups, each containing lots of objects, then the output from _summarize.m_ can be very long. In order to avoid this, there are a couple of ways to slim down its output. The most obvious is to only show you the names of the groups in the _subj_ structure, and not the names of the objects contained within the groups. See [\_How can I slim down the output from summarize.m\_](HowtosMisc#How_can_I_slim_down_the_output_from_summarize.m.md) for more information.


### Book-keeping and the headers ###

Every object (including the _subj_ structure itself) has a _header_ field. This is there to store information about how that object was created, and what processing has been done to it. All headers contain at least these fields:

_description_ ' an optional field that can be used to store a high-level sentence or two about what the object is for

_history_ ' a cell array of strings that gets automatically appended to by toolbox scripts, containing a freeform narrative about the object

_created_ ' a structure containing fields such as 'function\_name', 'patname' etc. The toolbox scripts automatically fill these in as a reminder of the time of creation, which function created the object, any arguments it used to do so, and which other objects were used by that function.

We find that these header fields can be very useful in keeping track of complicated analyses with multiple paths, comparing two paths to see how they differ, and reminding oneself months later about how a particular _subj_ structure came to be. Ensuring that your functions also append to these fields is a good idea.

The toolbox will automatically record the date and time every object is created (since all object creation is done by _[init\_object.m](http://code.google.com/p/princeton-mvpa-toolbox/source/browse/trunk/core/subj/init_object.m)_), as well as the stack at that moment (using _dbstack_). By inspecting this created.dbstack field, you should be able to tell which function (and which line) ordered the object to be created. If the function-writer was conscientious, they will have also saved all the argument values passed to the function, so that you can tell which objects were used to create that object (see [statmap\_template.m](http://code.google.com/p/princeton-mvpa-toolbox/source/browse/trunk/core/template/statmap_template.m) for examples of what kind of information might be useful to save).


### Storing other information ###

There are other kinds of information that might be worth storing. For instance, we haven't explicitly created a data structure for behavioral data, such as reaction times or errors. For now, we think it would be most natural to store such data as separate _patterns_ objects.

There is no explicit provision for structural/anatomical MRI scans, although these too could be stored as single-timepoint _patterns_.

There is currently no provision in the toolbox for mapping between data stored at different spatial or temporal resolutions, though we hope that the book-keeping machinery in the _subj_ structure will make life easier for users working in this area.


### What's the minimum you need to create a _subj_ structure ###

You need:

a dataset in a supported format (e.g. AFNI) that will become the first _pattern_

a one-of-n _regressors_ matrix stored as a Matlab matrix (or as a txt file that you can easily load in yourself)

a runs row-vector (or text file) that will become the first set of _selectors_

a _mask_ to apply to your dataset so that when you load it in with _load\_afni\_pattern.m_ (for instance), you only need to load in the voxels within the cranium

In fact, you can probably do without some of these. Your regressors don't have to be 1-of-n, depending on what you plan to do with them. And if you really really don't care where your features are in the brain, you can just create a 3D mask with the first two dimensions being singleton, e.g. newmask = zeros(1,1,500). Likewise, you could create a selector of all ones, though you'd have to figure out ways of partitioning things up for n-minus-one classification stuff.


## Further information ##

For further information, see the [Data structures Howto's and occasionally-asked questions](ManualDataStructures.md).