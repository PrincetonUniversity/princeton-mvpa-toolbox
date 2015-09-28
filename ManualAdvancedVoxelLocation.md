# Advanced Manual #

## Figuring out which voxel is which, and where ##

_Or "Dude, Where's My Voxel": A Guide to Relative Indices in MVPA by Chris Moore_

See also: [Howto's / Data structures / Masks](HowtosMasks.md).

In a perfect world, patterns stored in MVPA subject structures would be stored in their native space, in full dimensionality. But due to memory contraints and convenience, it is typically prudent to input and store a subset of the data, such as the voxels specified by a whole-brain mask. For this reason, loaded 3D patterns are stored in the _subj_ structure as two dimensional matrices.

It is important to note that the 3D information (xyz coordinates of voxels in a pattern) is _not_ stored in the pattern once it is loaded. Rather, all patterns are associated with the mask that was used in their creation. For instance, when calling _[load\_afni\_pattern.m](http://code.google.com/p/princeton-mvpa-toolbox/source/browse/trunk/core/io/load_afni_pattern.m)_, a required argument is the name of a map in the _subj_ structure used to mask the BRIK. The resulting pattern contains a field, masked\_by, which points to the mask that contains the 3D information.

The mask should be a boolean mask with the same dimensions as the data in its native space. The order of data in the pattern corresponds to the order of the voxels, such that one could recreate the dataset in its native space with the code:

```
>> data = get_mat(subj,'pattern','dataset'); 

>> masked_by = get_objfield(subj,'dataset','masked_by');

>> mask = get_mat(subj,'mask',masked_by);

>> full_data = zeros(size(mask));

>> full_data(find(mask)) = data; 
```

Note that this _only_ works for datasets and masks when the mask was used to create the dataset, thus ensuring proper relative indices, and the mask has not been altered in any way. In general, it is a good practice to never modify masks. If you wish to modify a mask, consider creating a duplicate, and modifying the duplicate. If you do modify a mask that was used to create a dataset, you will break the relative indices, and will not be able to recover the XYZ coordinates of each voxel in that pattern. In the worst case, you may not realise that this is the case, and be erroneously indexing your voxels.

Relative indices such as those above (e.g., find(mask)) only work under specific conditions, and can cause problems if not used properly. For instance, if we have a wholebrain data set, and mask it with an anatomical mask, we can create a 2nd pattern. If we then take this pattern and apply a functional mask, we create a 3rd pattern. The relative indices from the 3rd pattern to the 1st and 2nd are different. To avoid this confusion, they are never stored within the _subj_ structure. Relative indices should always be created on the fly between two objects, and never stored.

Relative indices between any two objects can be calculated by finding the intersection of two masks. Thus, when finding the relative indices for a pattern and a mask, the pattern must have a _masked\_by_ mask intact. The code for calculating relative indices is as follows:

```
>> data = get_mat(subj,'pattern','dataset'); 

>> masked_by = get_objfield(subj,'pattern','dataset','masked_by');

>> mask = get_mat(subj,'mask','masked_by');

>> new_mask = get_mat(subj,'mask','anat_mask');

>> [int ia ib] = intersect(find(mask), find(new_mask));
```

In this example, IA is the index of MASK in NEW\_MASK. IB is the inverse, the index of NEW\_MASK in MASK. Thus, one could take the relative index, IB, and extract the voxels in DATA that are present in the mask NEW\_MASK:

```
>> new_data = data(IB,:);
```

This is precisely what create\_thresh\_mask() does. We have included this guide to help users understand how relative indices were meant to work, and to facilitate integrating new functions, but urge the user to use the standard MVPA functions whenever possible. Happy coding.