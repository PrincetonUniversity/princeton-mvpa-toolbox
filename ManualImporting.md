# Importing #

The idea is that eventually the toolbox will be able to import from multiple sources into its own Matlab data structure, and export back in an equally trouble-free manner. For now, only the AFNI import process works.

It's worth noting that AFNI is free, multi-platform and supports the NIfTI-1 data format, which is intended to facilitate this kind of thing. You might be able to use AFNI as a kind of bridge from your analysis software to Matlab.

See also: [exporting](#_Exporting.md)


## From AFNI ##

See [''load\_afni\_pattern.m''](http://code.google.com/p/princeton-mvpa-toolbox/source/browse/trunk/core/io/load_afni_pattern.m) and [''load\_afni\_mask.m''](http://code.google.com/p/princeton-mvpa-toolbox/source/browse/trunk/core/io/load_afni_mask.m), which rely on [Ziad Saad's](http://afni.nimh.nih.gov/sscc/ziad) [AFNI-Matlab](http://afni.nimh.nih.gov/afni/matlab) library.

In short, the above scripts create a pattern or mask object and fill it with the contents of a BRIK file (or multiple BRIKs for patterns). They save the header information in the object's header field. Then, you're ready to go.

There is no facility for directly loading in 1D files, but Matlab's own ''load'' command should probably be sufficient. Just create an object of the right type (with [''init\_object.m''](http://code.google.com/p/princeton-mvpa-toolbox/source/browse/trunk/core/subj/init_object.m)'') ''and use [''set\_mat.m''](http://code.google.com/p/princeton-mvpa-toolbox/source/browse/trunk/core/subj/set_mat.m) to insert the loaded-in contents.

We are also working on a set of internal functions that call AFNI shell scripts from within Matlab to make certain things easier, e.g. convolving your regressors separately for each condition and run, or running n-minus-one 3dDeconvolve.

[Let us know](#_Contact_details.md) if there's any extra functionality you need.


## From BrainVoyager ##

We have a partial implementation of the BrainVoyager import process ' if it would be useful for you, please [contact us](#_Contact_details.md) and we can talk about pushing this forward.


## From SPM ##

We're some way towards an SPM import route, so if it would be useful for you, please [contact us](#_Contact_details.md) and we can talk about pushing this forward.