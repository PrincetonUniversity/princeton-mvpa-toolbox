# Advanced Manual #



# Troubleshooting, common errors and debugging #

## Undefined function or variable ##

Check your paths are right. If they're not, Matlab won't be able to find the toolbox functions to run them. The [Setup](Setup.md) instructions tell you how to fix your paths.


## Unable to read file 'blah': No such file or directory. ##

Check you're in the same directory as your data files. e.g. if you're trying to run the tutorial and you aren't in the directory that contains the sample data (which has to be [downloaded separately](http://www.pni.princeton.edu/mvpa/). Matlab's [cd](http://www.mathworks.com/access/helpdesk/help/techdoc/index.html?/access/helpdesk/help/techdoc/ref/cd.html) command will help you here.



## Error using ==> get\_number / No object called ##

The [get\_number.m](http://code.google.com/p/princeton-mvpa-toolbox/source/browse/trunk/core/subj/get_number.m) function is one of the central accessor functions that figures out which object you want, based on its name. This error probably means that you've typed something wrong at the command-line or in one of your functions, and that you're trying to get or set an object that doesn't exist. So check for typos, incorrect objtypes etc.


## Sometimes when using write\_to\_afni.m, I get this message: 'Problem using spoofing write method - trying again with zeroifying - you can safely ignore this message and the following error stack' ##

See Howtos / Exporting / [Sometimes when using write\_to\_afni.m](HowtosExporting#Sometimes_when_using_write_to_afni.m,_I_get_this_message:_Proble.md).


## Out of memory errors ##

See Advanced / [Managing memory](ManualAdvancedMemoryManagement.md).


## Invalid MEX-file error ##

The toolbox uses a small number of MEX files (compiled C files) for speed, e.g. compute\_xcorr.c. These have to be compiled separately for each platform - google for 'matlab mex' for more info. We aim to provide .mex files for at least linux and mac. Email mvpa-toolbox@googlegroups.com if you think they're missing from a release.