# Princeton multi-voxel pattern analysis manual #


Welcome to the Manual for the Princeton Multi Voxel Pattern Analysis Toolbox.

If you're new to this site, you will probably want to check
out [Setup](Setup.md) for installation instructions, then [Tutorials](Tutorials.md) to
get started, and finally [Manual](Manual.md) for more detailed coverage.

Below you'll find the Table of Contents for the Manual itself, on the left you can use the Sidebar to access the Manual directly, as well as the quick start guides and other relevant information.


## Table of Contents: ##
  * [What is the MVPA Toolbox?](ManualWhatIsMVPA.md)
  * [Data Structures](ManualDataStructures.md)
    * [Patterns](ManualDataStructures#Patterns.md)
    * [Regressors](ManualDataStructures#Regressors.md)
    * [Selectors](ManualDataStructures#Selectors.md)
    * [Masks](ManualDataStructures#Masks.md)
    * [Chronology](ManualDataStructures#Chronology.md)
    * [The \*Subj\* Structure](ManualDataStructures#The_Subj_Structures.md)
  * [Importing](ManualImporting.md)
    * [AFNI](ManualImporting#From_AFNI.md)
    * [BrainVoyager](ManualImporting#From_BrainVoyager.md)
    * [SPM](ManualImporting#From_SPM.md)
  * [Pre-Classification](ManualPreClassification.md)
    * [Zscoring](ManualPreClassification#Zscoring.md)
    * [Anova and Voxel Selection](ManualPreClassification#Anova_and_voxel_selection.md)
    * [Other Methods of Voxel Selection](ManualPreClassification#Other_voxel_selection_methods.md)
    * [Statmaps](ManualPreClassification#Statmaps.md)
      * [Creating your own](ManualPreClassification#Creating_your_own_statmap.md)
    * [Peeking](ManualPreClassification#Peeking.md)
  * [Classification](ManualClassification.md)
    * [Introduction](ManualClassification#Introduction_'_training,_testing_and_generalization.md)
    * [Performance](ManualClassification#Performance.md)
    * [Creating your own Performance Metric Functions](ManualClassification#Creating_your_own_performance_metric_function.md)
    * [N Minus One Cross Validation](ManualClassification#N-minus-one_(leave-one-out)_cross-validation.md)
    * [Backpropagation](ManualClassification#Backpropagation.md)
    * [Included Classifiers](ManualClassification#Included_classifiers.md)
    * [Creating a Training Function](ManualClassification#Creating_your_own_training_function.md)
    * [Creating a Test Function](ManualClassification#Creating_your_own_testing_function.md)
    * [Results Structure](ManualClassification#The_results_structure.md)
    * [Avoiding Spurious Classification](ManualClassification#Avoiding_spurious_classification.md)
  * [Exporting](ManualExporting.md)
    * [AFNI](ManualExporting#To_AFNI.md)
    * [Brain Voyager](ManualExporting#To_BrainVoyager.md)
    * [SPM](ManualExporting#To_SPM.md)
  * [Advanced](ManualAdvanced.md)
    * [Conventions](ManualAdvanced#Conventions.md)
    * [Memory Management](ManualAdvanced#Managing_memory.md)
    * [Writing MVPA Patterns to Disk](ManualAdvanced#Moving_patterns_to_the_hard_disk.md)
    * [Removing Objects](ManualAdvanced#Removing_objects.md)
    * [Direct Access to the \*subj\* Structure](ManualAdvanced#Accessing_the_subj_structure_directly.md)
    * [Identifying Which Voxel is Which](ManualAdvanced#Figuring_out_which_voxel_is_which,_and_where.md)
    * [Handy Shortcuts](ManualAdvanced#Handy_shortcuts.md)
    * [Creating Custom MVPA Functions](ManualAdvanced#Creating_custom_functions.md)
    * [Utilizing Optional Arguments](ManualAdvanced#Optional_arguments.md)