# Introductory tutorial (SPM) #


---

## Getting SPM files ##
The SPM Read/Write functions are included in both the V 1.0 release of MVPA and the [SVN](SVN.md) version of MVPA, If you wish to use nifti files you will need the [SVN](SVN.md) checkout version of MVPA.

There are now two sets of data for this version of tutorial easy, one for [Nifti](http://www.csbmb.princeton.edu/mvpa/downloads/nifti_set.tar.gz) and a second for [Analyze](http://www.csbmb.princeton.edu/mvpa/downloads/analyze_set.tar.gz) formatted data.

[SVN](SVN.md)

## Introduction ##
This tutorial is based on TutorialIntro, but uses ANALYZE/SPM import/export functions and data. This is '''not a complete tutorial''' - it assumes that you've already run TutorialIntro with the AFNI sample data (or at least read it through), and now you want to run things with the sample ANALYZE data instead.

Specifically, this analysis will use an ANALYZE dataset (converted from AFNI) from Haxby et al (Science, 2001) that is provided with the toolbox, in which participants viewed different classes of visual objects. Just as in TutorialIntro, the goal of the analysis is to classify the distributed patterns of neural activity in order to predict psychological states (i.e., viewing a face) from the neural state (e.g., BOLD pattern in ventral temporal cortex) .

The ANALYZE/SPM import/export scripts are currently considered stable, and are available as part of the main MVPA toolbox distribution. Please contact us at mvpa-toolbox@googlegroups.com for if you are having any trouble with the SPM functions.

## SPM Specific Information ##
  * Important:  the SPM5 software library package has a few behaviors which we are unfortunately incapable of controlling as of the current version of the software.
    * Normalization: SPM5 appears to normalize all files opened using the library.  The data is normalized to the bottom right hand of the data set so if your looking for your data and it isn't where you put it, look down and right.
    * Flipping:  As part of the above the data will be flipped as well if it doesn't contain the proper transformations to indicate it's alignment (usually included as a .mat file).  There is beta control for this behavior in the spm loading code that can be activated by setting the value beta to 1 and then the value flipped to 1 if you've stored your data flipped or to 0 if you have not.  This is important as it affects the alignment of your data and is something to bear in mind when opening files.  If you know the alignment for all your data is the same you can segway past this issue by modifying the 'spm\_defaults' file to explicitly set the flipping behavior and then by simply calling the spm\_defaults file before you begin loading data.

## Ventral temporal with GLM mask ##
Before loading in our data, we first need to create a ''mask'' to restrict the voxels we want to allow through:

```
>> subj = load_spm_mask(subj,'VT_category-selective','mask_cat_select_vt.img');
```

## EPI pattern ##
Loading in the data is almost as simple. We're going to create a pattern'' object called 'epi' to store our raw EPI voxel data. This pattern is only going to include voxels that were allowed through by the mask we just created called 'VT\_category-selective'. ''

Because your data may be big and stored in multiple spm .img/.hdr file pairs, load\_analyze\_pattern.m'' takes a cell array of strings as its ''filenames'' argument ''''. We will create this list first. '''''''' '''

```
>> for i=1:10  
     index=num2str(i);
     raw_filenames{i} = ['haxby8_r' index '.img'];
end

>> subj = load_spm_pattern(subj,'epi','VT_category-selective',raw_filenames);


Pattern 'epi' created by load_spm_pattern 
```

Note: The above will open the relevant Analyze formatted data.  To load the Nifti formatted data instead replace the file extension '.img' with the extension '.nii'

## Cross-validation classification ##
```
>> class_args.train_funct_name = 'train_bp';

>> class_args.test_funct_name = 'test_bp';

>> class_args.nHidden = 0;
```

If you don't have the Matlab toolbox, you can use the Netlab open source toolbox instead. It seems to require a hidden layer, so try this instead of the above:

```
>> class_args.train_funct_name = 'train_bp_netlab';

>> class_args.test_funct_name = 'test_bp_netlab';

>> class_args.nHidden = 10;
```

Also you can replace the above train and test parameters with 'train\_gnb' and 'test\_gnb' if you would like a deterministic analysis to be done.  If you look at the files 'tutorial\_easy\_afni' and 'tutorial\_easy\_spm' you will see that these are the tests used in those files.  These files are used for both demonstration and testing purposes (as part of the unit testing suite) and it is recommended you do not modify them.

## Troubleshooting ##
This should work flawlessly, straight out of the box. No, really, it should.  If it doesn't, have a look at the [Troubleshooting](Troubleshooting.md) page. If absolutely none of that helps, [let us know](mailto:mvpa-toolbox@googlegroups.com).