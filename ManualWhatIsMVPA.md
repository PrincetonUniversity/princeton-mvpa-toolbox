# What is the toolbox? #

This is what you get when you hand over your money (price currently stable at $0).


## Sample dataset ##

10 runs from a single subject of Haxby et al.'s (Science, 2001) 8-category study.

Note: we have made no efforts to check that the sample data set is valid or that it has been processed the same way as the published data. It's included for tutorial purposes only.


## Tutorial and acccompanying script ##

Sample script ([tutorial\_easy.m](http://code.google.com/p/princeton-mvpa-toolbox/source/browse/trunk/core/tutorial_easy.m)) that runs a basic analysis of the Haxby et al. dataset. This is accompanied by a [line-by-line description](TutorialIntro.md) of what's going on - this tutorial is the very best place to start with the toolbox.


## Documentation ##

The _docs_ subdirectory includes beautified html versions of the m-files, but this [online wiki](http://code.google.com/p/princeton-mvpa-toolbox/wiki/Manual) is really the best place to look.


## Mathworks toolboxes ##

We optionally rely on the [Mathworks](http://www.mathworks.com/) toolboxes described below at some points in the toolbox. However, they are not bundled with the toolbox and must be purchased separately.

The non-parametric wavelet-based statistical functions (e.g. [WAVESTRAPPER\_RESULTS.M](http://code.google.com/p/princeton-mvpa-toolbox/source/browse/trunk/core/learn/wavestrapper_results.m)) require the Matlab Wavelets toolbox.


### Statistics ###

By default, [zscore\_runs.m](http://code.google.com/p/princeton-mvpa-toolbox/source/browse/trunk/core/preproc/zscore_runs.m) and [statmap\_anova.m](http://code.google.com/p/princeton-mvpa-toolbox/source/browse/trunk/core/preproc/statmap_anova.m) require the _anova1.m_ and _zscore.m_ functions from the Statistics toolbox. However, we have provided home-grown alternatives that function similarly (though not identically). Just set the optional 'use\_mvpa\_ver' flags to true as described in the functions' help to use the home-grown functions instead.

Update: we've since realized that even our homegrown STATMAP\_ANOVA.M relies on some of the scripts from the Statistics toolbox. If you have trouble with this, let us know. We're starting to recommend that people avoid the ANOVA and use the GLM from AFNI or otherwise anyway. See TutorialAfniGlm for info on how to do this. Also, if there any Octave experts out there, shout out and maybe we can see about borrowing some Octave code to function in place of the Statistics toolbox.


### Neural networks ###

The Mathworks [Neural Networks](http://www.mathworks.com/products/neuralnet/) toolbox is required for the [train\_bp.m](http://code.google.com/p/princeton-mvpa-toolbox/source/browse/trunk/core/learn/train_bp.m) and [test\_bp.m](http://code.google.com/p/princeton-mvpa-toolbox/source/browse/trunk/core/learn/test_bp.m) functions, but you can use [train\_bp\_netlab.m](http://code.google.com/p/princeton-mvpa-toolbox/source/browse/trunk/core/learn/train_bp_netlab.m) and [test\_bp\_netlab.m](http://code.google.com/p/princeton-mvpa-toolbox/source/browse/trunk/core/learn/test_bp_netlab.m) instead, which rely on the bundled open source [Netlab](http://www.ncrg.aston.ac.uk/netlab/) toolbox (see External bundled packages / Netlab] below).


## External bundled packages ##

We have been generously allowed to bundle the following packages by their authors. Although we have done some minimal testing, we haven't made any serious efforts to scrutinise their innards ' please [let us know](#_Contact_details.md) if you find a bug in them, but don't hold us responsible.


### AFNI-Matlab ###

We rely heavily on [Ziad Saad's](http://afni.nimh.nih.gov/sscc/ziad) [AFNI-Matlab](http://afni.nimh.nih.gov/afni/matlab) toolbox for all of the [importing from](#_From_AFNI.md) and [exporting to](#_To_AFNI.md) AFNI.


### Netlab ###

If you don't have the Mathworks Neural Networks toolbox, you can use [Ian Nabney's](http://www.ncrg.aston.ac.uk/People/nabneyit/Welcome.html) [Netlab open source neural networks toolbox](http://www.ncrg.aston.ac.uk/netlab/) instead, although [train\_bp\_netlab.m](http://code.google.com/p/princeton-mvpa-toolbox/source/browse/trunk/core/learn/train_bp_netlab.m) doesn't currently support all of the functionality in [train\_bp.m](http://code.google.com/p/princeton-mvpa-toolbox/source/browse/trunk/core/learn/train_bp.m).


### Boosting ###

By the time you read this, the wrapper for the boosting classifier should be ready (or available upon [request](mailto:mvpa-toolbox@googlegroups.com)). This requires the user to download the appropriate [binaries](http://www.research.att.com/cgi-bin/access.cgi/as/vt/ext-software/www-ne-license.cgi'table.BoosTexter.binary). We're also working on a Matlab-only version.


### Subversion ###

The [Subversion](http://subversion.tigris.org/) (SVN) version control system is not bundled with the toolbox in any way, but we do rely heavily on it (along with the [Trac](http://trac.edgewall.org/) add-on) for internal development, and are extremely grateful for its existence.


### Montage ###

We use Keith Schneider's montage library for visualizing brain maps. See TutorialVisualization.