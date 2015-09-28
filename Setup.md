# Princeton multi-voxel pattern analysis setup and installation guide #

---

> 


---

## Before you begin ##

### Compatibility and requirements ###

Almost all of the testing for the toolbox has been using Matlab [R14](https://code.google.com/p/princeton-mvpa-toolbox/source/detail?r=14) (version 7) on Linux and Mac OS X, though we don't anticipate any major roadblocks getting things to work on other operating systems. One user has reported that a few minor tweaks are necessary to get things working for version 6.5, and so we advise using version 7 wherever possible. Currently, none of the scripts require the Java Virtual Machine. Please [contact us](mailto:mvpa-toolbox@googlegroups.com) if you notice any compatibility issues.

Update: Keith Bartley has written [OctaveMVPA](https://github.com/bartleyneuro/OctaveMVPA), a port to Octave (for those without Matlab licenses).

The default ANOVA and zscoring functionality require the Matlab Stats toolbox, although home-grown alternatives have been provided instead for your use. Likewise, the default backpropagation classifier needs the Neural Networks toolbox, but we have bundled the Netlab open source toolbox that you can use instead. See the 'Mathworks toolboxes' and 'External bundled packages' in the [Manual](Manual.md) for more information.

### Downloading the toolbox ###
The latest version can always be found at:

http://code.google.com/p/princeton-mvpa-toolbox/wiki/Downloads

See the contact details in the [Manual](Manual.md) for more information about mailing lists.

There are two parts to download: the scripts and the sample dataset. You only really need the sample dataset if you want to try running through the tutorial (highly recommended).

## Installation ##
### Unpack the toolbox scripts ###
The main scripts are stored in a gzipped tarball file called mvpa._version_.tar.gz. Unpack this as follows:

  * On any form of Unix (including Linux and Mac OS X): change directory to where you saved the .tar.gz file, and type tar 'zxvf mvpa._version_.tar.gz

This just says to unzip and unpack the contents, showing you the names of the files as it goes.

  * On Windows, use a program like [Winzip](http://www.winzip.com/) or [WinRAR](http://www.rarlab.com/). (Update: some users have experienced problems using WinZip, so we currently recommend WinRAR.)

This will create various directories:

  1. _afni\_matlab_, for importing from AFNI
  1. _bv2mat_, for importing from BrainVoyager
  1. _mvpa_, the main toolbox scripts
  1. _netlab_, for neural networks classification, if you don't have the Matlab Neural Networks toolbox
  1. _progress_, changelogs, planned improvements etc. ' no actual functionality here
  1. _montage kas, scripts by Keith Schneider for making montage views of fMRI data_

mvpa _is the one with all the toolbox scripts, and_ mvpa/docs _contains all the documentation, including a copy of this file. See 'What is the toolbox_ in the ["MVPA manual"] for more detailed information about the other directories.

### Unpack the sample dataset ###
You're also going to need to store a copy of the sample dataset files: just unpack the afni\_set.tar.gz file as before, and it should create a tutorial\_easy directory containing some AFNI _.BRIK_, _.HEAD_ and Matlab _.mat_ files.  Alternatively you can use the nifti\_set or analyze\_set to run tutorial\_easy\_spm for those file formats.

### Set the Matlab paths ###
Now you need to set your paths, so that when you run matlab, it will know about the toolbox m-files. One easy way is create a _startup.m_ in _~/matlab_ that Matlab will run every time it opens, and add the _addpath_ command to that.

Note: if you don't have a _~/matlab_ directory, just create one first.

Note for Windows users: I'm not sure what the Windows equivalent of _~/matlab_ is. Try something like _c:\matlab\work_, or _c:\program files\matlab\_ or _My Documents_ ' let me know which works.

A sample _startup.m_ would look like this:

```
addpath ~/mvpa 

mvpa_add_paths;
```

Test that this is working by running Matlab while in another directory. Type:

```
>> help tutorial_easy 

[SUBJ RESULTS] = TUTORIAL_EASY() 
```

This is the sample script for the Haxby et al. (Science, 2001) 8-categories study. See the accompanying tutorial\_easy.htm

If you see the above, you're in good shape. If not, your paths haven't been set correctly.

### Compile C-Language .MEX files ###
_N.B. We bundle a few already-compiled versions of the compute\_xcorr mex file in the toolbox now, so you probably won't need to worry about compiling it yourself - in that case, you can skip this section._

Several of the more advanced features of the toolbox involving the computation of statistical maps using a correlation function.  If you want to speed up the computeation of cross correlation statistical maps (and you most certainly do, we can assure you), you can compile the C-language version of the statmap\_xcorr.m function. To do this, first start Matlab, and switch to your `mvpa` directory that contains the core MVPA scripts.  Then enter the following command:

```
>> mex compute_xcorr.c
```

One of two things should happen. You should get output that looks vaguely like this:

```
compute_xcorr.c: In function `mexFunction':
compute_xcorr.c:123: warning: assignment discards qualifiers from pointer target type
compute_xcorr.c:124: warning: assignment discards qualifiers from pointer target type
```

Or, Matlab might complain that you don't have a default compiler selected. If this is the case, follow the directions from the Matlab documentation here to select a compiler, or simply select the gcc compiler if it's available. Then run the mex compute\_xcorr.c command again, and you should get the desired output above.


### A Few Articles on Using and Troubleshooting Mex ###

  * [Mathworks Mex Files Guide, including basic troubleshooting](http://www.mathworks.com/support/tech-notes/1600/1605.html)
  * [Matlab Article for configuring Mex](http://www.mathworks.com/access/helpdesk/help/techdoc/index.html?/access/helpdesk/help/techdoc/matlab_external/f29502.html&http://www.google.com/search?q=using+matlab+mex&ie=utf-8&oe=utf-8&aq=t&rls=org.mozilla:en-US:official&client=firefox-a)
  * [Matlab Article for using Mex to run C and Fortran programs](http://www.mathworks.com/access/helpdesk/help/techdoc/index.html?/access/helpdesk/help/techdoc/matlab_external/f29502.html&http://www.google.com/search?q=using+matlab+mex&ie=utf-8&oe=utf-8&aq=t&rls=org.mozilla:en-US:official&client=firefox-a)
  * [Matlab Article for using debuggers with Mex files](http://www.mathworks.com/access/helpdesk/help/techdoc/index.html?/access/helpdesk/help/techdoc/matlab_external/f32489.html&http://www.google.com/search?q=matlab+mex+debugging&ie=utf-8&oe=utf-8&aq=t&rls=org.mozilla:en-US:official&client=firefox-a)
  * [An article detailing a simple Step-by-Step process for creating a Mex file](http://cnx.org/content/m12348/latest/)

## Start your engines ##
Ok, we're ready to go. Change directory to where your sample data was stored and run matlab. Then, follow the instructions in the [tutorial](TutorialIntro.md).

Things are still in a state of flux, and we expect to be finding and fixing bugs for a little bit longer. To minimize your own and others' suffering, we ask that you let us know as soon as possible if you've found any serious bugs. Also, please contact mvpa-toolbox@googlegroups.com to be added to our mailing list so that we can let you know of any major new releases or bugfixes.

Good luck.