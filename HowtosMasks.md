# Howtos #

## Masks ##

### How do I figure out which voxels are common to two masks' ###

This is very easy. Since masks are boolean 3D matrices, you could just try:

```
>> mask1 = get_mat(subj,'mask','mask1'); 

>> mask2 = get_mat(subj,'mask','mask2');

>> common_voxels = mask1 & mask2; 
```

That will produce a third boolean 3D matrix, with 1s where both mask1 and mask2 had 1s. You could then create a new common\_voxels mask object, and use this to mask a pattern using [create\_pattern\_from\_mask.m](http://code.google.com/p/princeton-mvpa-toolbox/source/browse/trunk/core/subj/create_pattern_from_mask.m).


### How do I find the coordinates of active voxels in a mask' ###

The mat of a mask object is a 3D boolean object. If you would like an (_nVox_ x _3_) matrix of _x_/_y_/_z_ Cartesian coordinates listing those voxels that are active in the volume:

```
>> mymask = get_mat(subj,'mask','mymaskname'); 

>> [x y z] = ind2sub(size(mymask),find(mymask)); % untested xxx 
```


### How do I create a mask that allows all the features through' (Creating a wholevol mask) ###

The volume collected by the fMRI scanner is a cuboid. Normally, you'll probably only want to include the voxels inside the cranium but you may want a mask that includes absolutely every single one of those voxels, which we will term a 'wholevol' mask. It's often useful to try your voxel selection methods on wholevol masks as a sanity-check. If many of the voxels getting selected are outside the brain, that's a bad sign.

All you need to do is create an all-ones 3D matrix. If your volume is 64x64x40:

```
>> wholevol = ones(64,64,40); 

>> subj = init_object(subj,'mask','wholevol');

>> subj = set_mat(subj,'mask','wholevol',wholevol); 
```

Then, if you want to load in the data for every single voxel from some BRIK file, then you would call [load\_afni\_pattern.m](http://code.google.com/p/princeton-mvpa-toolbox/source/browse/trunk/core/io/load_afni_pattern.m) as before, using `wholevol` as the mask argument, e.g.

```
>> for i=1:10 

raw_filenames{i} = sprintf('haxby8_r%i+orig',i);

end

>> subj = load_afni_pattern(subj,'epi','wholevol',raw_filenames); 
```

Note: this could involve loading in hundreds of thousands of voxels' worth of data, which will probably be too RAM-intensive to be manageable. There's not a lot you can do about this. Storing the data as singles, rather than doubles is probably a good start ' see [How do I store an object as singles rather than double](HowtosMisc#How_do_I_store_an_object_as_singles_rather_than_doubles.md).


### Creating a wholebrain (intra-cranial) mask, or other anatomical mask ###

Currently, there are no facilities in the toolbox for automatically defining the cranial boundaries to create intra-cranial masks, or for drawing anatomical ROIs. We recommend that you use a function like AFNI's 3dAutomask for defining intra-cranial boundaries, or draw the ROIs yourself, save to a BRIK file, and then use [load\_afni\_mask.m](http://code.google.com/p/princeton-mvpa-toolbox/source/browse/trunk/core/io/load_afni_mask.m) to read that mask in to Matlab.

For information about other neuroimaging packages, see [Importing](ManualImporting.md).