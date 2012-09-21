This set of tools is provided by Alex Ahmed (alex.ahmed AT yale DOT edu) 
of Yale University for the purposes of importing Brainvoyager data into 
Matlab/MVPA. 

To use this package you will need to have a copy of the NeuroElf I/O 
functions (http://neuroelf.net/)in your Matlab PATH because it is used 
to import the actual BV data. 

The package consists of modified versions of load_afni_pattern and mask 
repurposed to load brainvoyager data and a helper function that may be 
useful as a referrence for importing VTC files, it however appears to be 
lab workflow specific so YMMV. The primary new tools are named 
load_bv_mask-AA and _pattern-AA. To enable these functions you will need 
to edit your 'mvpa_add_paths' to uncomment the line 
"%myaddpath('contrib/io/BV');" to enable these functions.

As this is an external contribution, it has the same level of support as 
other contributed files. Namely that it recieves as much or as little 
support as the original author is willing to provide. 

In addition to these scripts you will need to manually create a 
regressor table in the format expected by MVPA and save it as a .mat 
file for use with your data. This is due to there being no readily 
available way to import Brainvoyager PRT protocol files. 

-Garrett McGrath
Sysadmin Princeton Neuroscience Institute
gmcgrath AT princeton DOT edu