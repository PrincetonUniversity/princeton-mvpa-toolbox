# News and Updates #

### 01-14-2014 - Octave port ###

Update: Keith Bartley has recently written [OctaveMVPA](https://github.com/bartleyneuro/OctaveMVPA), a port to Octave (for those without Matlab licenses).

### 07-01-2009 - v1.1 Released ###

The latest version of MVPA has officially been released, this release is a combination bug-fix and general maintenance release. See the Google Groups mailinglist for more information on the bug, which is related to the train\_logreg.m file. Thanks to Jesse Rissman for finding this bug and reporting it.

### 1-09-2009 - Updates to Analyze and Nifti File Handlers ###

The latest svn version of the load/write spm file handlers now feature Nifti support. Nifti files can be opened in the same manner as Analyze files up till this point and the write\_to\_spm function now defaults to writing out a Nifti file with the ability to override the current file format using the optional arguement 'FEXTENSION'.

The unit tests have been updated to reflect this and new versions of the data have been posted on the download page. Each of the data sets now includes everything you need to run the tutorial\_easy for that data format and the associated unit tests. Note: to run the unit tests for the Nifti/Analyze data you will also need the Afni data set.
### 4-14-2008 - Version 1.0 Released ###

We are proud to announce version 1.0 of the MVPA Toolset. The link below will allow you to download the newest official release of the software, and of course you can always keep yourself up to date using the SVN links in our wiki. Please see the file progress/changelog\_1.0.txt for a comprehensive list of all of the changes.

### 2-23-2008 - New public discussion list created ###

From now on, we'll be using mvpa-toolbox@googlegroups.com as our public discussion list. Feel free to join or browse the archives.

### 2-08-2008 - Thomas Wolbers contributions added to SVN ###

Thomas Wolbers was nice enough to send us a set a high pass filter script and detrending script. They have been officially added to the mvpa SVN. This new functionality can be found in core/preproc and the file names are hpfilter\_runs.m and detrend\_runs.m. You will need the SPM library to make hpfilter\_runs.m function (it relies upon spm\_filter.m).

### 2-07-2008 - Public access to the Subversion development repository ###

From now on, the Subversion development repository containing the latest versions of all the core MVPA toolbox scripts will be publicly available. If you want to live on the bleeding edge, or need functionality that hasn't made its way into one of the official releases, you can grab anything you're missing from here. For information on what a Subversion version control system is and how to access it, see the wiki page.

### 2-06-2008 - SPM import/export scripts ###

We have officially released the beta scripts for importing and exporting ANALYZE files (e.g. from SPM) directly into/out of the MVPA toolbox. These rely on SPM's import/export scripts, wrapped to make use of MVPA toolbox data structures.

We've done our best to test them carefully, but we advise users to read the documentation about them before use, to pay close attention to what they produce, and to let us know if anything seems awry.

You can access them from the Subversion repository or as a separate download (see the 'Download' section below). Data for testing the scripts has been included as well.

### 2-05-2008 - Using Python for multi-voxel pattern analysis ###

If you like the idea of multi-voxel pattern analysis, but don't or can't use Matlab, then you may be interested in PyMVPA. This is a Python-based toolbox similar in spirit to our Matlab MVPA toolbox, written by Michael Hanke, Yaroslav Halchenko, Per Sederberg and the rest of the Debian Experimental Psychology crew.

### 5-02-2007 - Version 0.9 of the toolbox released ###

Let us know if you have any problems!

### 3-25-2007 - Gearing up for the 2007 EBC/PBAIC competition ###

The 2007 Pittsburgh (EBC) brain activity interpretation competition is kicking off. In the webcast, Walt Schneider and Greg Siegle said that the data will be provided in a standard Matlab format, and also in an MVPA toolbox 'subj' structure.

### 8-16-2006 - EBC Competition Extension Data Now Available ###

The tutorial dataset for the EBC Extension has been released. You can now download everything you need to run the tutorial and generate EBC submissions for movies 1 and 2. Furthermore, as of MVPA version 0.8, the EBC Competition Extension is included as part of the standard MVPA releases. You will no longer need to install the EBC toolbox separately.

Please see the EBC Extension page for more information.

### 7-7-2006 - MVPA Toolbox 0.8 released ###

Version 0.8 of the MVPA toolbox beta has been released, and is now available for download. It should be fully backwards compatible with previous releases. This is also the first release to use our new wiki documentation system - bear with us while we straighten this out, and feel free to get involved in editing. Just create a login for yourself, and away you go. For a more detailed list of the changes between 0.8 and 0.7.1, please see the changelog.

### 6-23-2006 - EBC Competition/OBHM 2006 Extension 0.3 Release! ###

A beta version of the EBC Competition extension for the MVPA toolbox has been released. This release contains all of the optimizations used in the Princeton EBC Team's prize winning entry, so that users may replicate their results. Please see the EBC Extension page for more information.