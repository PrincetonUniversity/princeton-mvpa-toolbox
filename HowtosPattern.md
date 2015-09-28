# Howtos #

## Patterns ##


### What pre-processing should I do ###

We don't yet have strong recommendations for the pre-processing you should do on your data. Often, people in the Princeton Psychology Department do volume registration/motion correction, despiking, detrending (linear and sometimes quadratic) and sometimes spatial smoothing.

If you find that some kinds of pre-processing steps systematically affect multi-voxel or classification analysis, we'd be very interested to [hear from you](ContactDetails.md) for future releases.


### What if I want to use Blah<sup>TM</sup> to import my patterns ###

If you want to use a different neuroimaging pre-processing package (e.g. BrainVoyager, SPM) then read the ['Importing'](ManualImporting.md) section to see what importing paths are currently supported. If your package of choice isn't supported, [let us know](ContactDetails.md). If you feel like contributing load\_blah\_pattern.m'' and ''load\_blah\_mask.m'' import functions, that would be even better. ''

Alternatively, you may find that your favoured package and one of the supported packages can read/write each others' format. AFNI and SPM are both pretty versatile, and many packages are adding support for the new [NIfTI](http://nifti.nimh.nih.gov/) format.

Finally, if you just want to read in data from some other source entirely, then that's easy. As long as you can get the data into Matlab as a 2D (nFeatures x nTimepoints) matrix, then you can simply call [m2html/init\_object.html init\_object.m''] and then [m2html/set\_mat.html ''set\_mat.m''] to create a new pattern object and insert your matrix into it. You should also read [:MVPA manual:How do I create a pattern without a mask] if you're going to do this. ''


### How do I create a pattern without a mask ###

The toolbox intentionally makes this hard to do. There's a good reason for this ' if you want to know where a feature/voxel in your pattern came from, or find the same voxel in two patterns that have been differently masked, then you need to have a common reference space that you can map between. A pattern without an associated mask contains anonymous, untraceable features.

If that's what you really want, or you just want to try something quick and dirty, the easiest work-around is to just create a place-holder mask:

```
>> nFeatures = 100; 

>> subj = init_object(subj,'mask','placeholder');

>> placeholder = ones([1 1 nFeatures]);

>> subj = set_mat(subj,'mask','placeholder',placeholder);

>> subj = init_object(subj,'pattern','my_pattern');

>> subj = set_objfield(subj,'pattern',new_patname,'masked_by','placeholder'); 
```


### How do I figure out which features are common to two patterns ###

This isn't much harder than finding the common voxels in two masks. Since each pattern has a masked\_by'' field, start by extracting the masks used by your two patterns. ''

```
>> mask1_name = get_objfield(subj,'pattern','pat1','masked_by'); 

>> mask2_name = get_objfield(subj,'pattern','pat2','masked_by');

>> mask2 = get_mat(subj,'mask','mask2');

>> common_voxels = mask1 & mask2; 
```

Now, just refer to ' [:MVPA manual:How do I figure out which voxels are common to two masks] ' to compare the two masks.


### How do I exclude features from a pattern ###

Don't just delete the features and then call set\_mat.m''. In fact, if you do, it will warn you that the dimensions of the new mat are different. This is an indication that what you are doing isn't a good idea. ''

Instead, you should create a mask with just the features you want, and then create a new pattern that is masked by your new mask. This may seem like a lot of work, but there's a very good reason for it. As discussed in '[Figuring out which voxel is which, and where](#_Figuring_out_which.md)', a pattern doesn't contain any information about its features except their values. If you want to compare voxels from different-sized patterns, or figure out where in the brain the features come from, you need to use a mask as a reference space. That is why every pattern has a masked\_by'' field, pointing to a mask with the right number of active voxels. ''

The following snippet should give you an idea of what you need to do, if you want to delete the 100th voxel from the epi\_wholebrain'' pattern which is masked by the ''wholebrain'' mask. It first creates a new ''wholebrain2'' mask, sets the 100th voxel in that to 0, then calls [m2html/create\_pattern\_from\_mask.html ''create\_pattern\_from\_mask.m'']'' ''to do the hard work of creating a new ''epi\_wholebrain2 ''pattern that will be masked by ''wholebrain2'', and so lack the 100th voxel. ''

```
>> subj = duplicate_object(subj,'mask','wholebrain','wholebrain2'); 

>> wholebrain2 = get_mat(subj,'mask','wholebrain2');

>> wb_idx = find(wholebrain2);

>> vox_to_delete = wb_idx(100);

>> wholebrain2(vox_to_delete) = 0;

>> subj = set_mat(subj,'mask','wholebrain2',wholebrain2);

>> subj = create_pattern_from_mask(subj,'epi_wholebrain','wholebrain2','epi_wholebrain2'); 
```


### How do I store a pattern as singles rather than doubles ###

See [:MVPA manual:How do I store an object as singles rather than doubles].


##### Can the toolbox help me load BRIKs #####

Even if you're not using most of the toolbox's functionality, it provides wrappers for Ziad Saad's afni\_matlab library that might make importing/exporting easier.

If all you want to do is to load in a BRIK, then BrikLoad.m'' in the afni\_matlab library is all you need. If you want to load in a BRIK, apply a mask, and end up with a matrix of nVoxels by nTimepoints (as used by the toolbox), then you're probably better off using the toolbox's ''load\_afni\_pattern.m'' (and ''load\_afni\_mask.m''). This way, you don't need to worry about indexing, keeping track of which voxel is which or where etc. See ''Advanced / ''[''Keeping track of which voxel is which, and where''](#_Figuring_out_which.md), for more information. ''

See also: Howtos / Exporting / ''[''Can the toolbox help me write BRIKs](#_Sometimes_when_using.md). ''