# Advanced Manual #

### Good practices - do's and don't's ###

#### Don't access the subj structure directly ####

See [Accessing the subj structure directly](ManualAdvanced#Accessing_the_subj_structure_directly.md).

Use the accessor functions in order to evade the ghostly voice that utters 'I told you so' for weeks after tracking down tricky bugs that the accessor functions would have precluded.


#### Lower-case ####

Although we have followed the Matlab convention of referring in the comments help to functions and variables using upper-case, all of the functions, variables and arguments in the toolbox are lower-case.

Try and avoid upper-case whenever using toolbox functions or arguments, since it could cause a bug that might be difficult to trace.


#### Be careful with the subj .x shortcuts ####

We added a facility for [getting the highest-numbered objects names](ManualAdvancedShortcuts#Getting_the_latest_object_names.md), but we're still not sure if this is a good idea. If you rely heavily on this, you may accidentally refer to an unintended object, but it can make life easier too.


#### Recommended early pre-processing ####

See [What pre-processing should I do](HowtosPattern#What_pre-processing_should_I_do.md)


#### Should I split my experiment up other than by runs? ####

It depends a little. The more runs you have, the higher proportion of your experiment you'll be training on, which is probably a good thing

However, unless I would definitely advise splitting the runs according to your actual experimental design:

- if you were to concatenate runs together, you'd have issues with baseline drift

- if you were to split runs up, then you ought to make sure that you don't end up training and testing on contiguous TRs. Training and testing on contiguous TRs might artificially boost classifier performance. however, if there are big enough rest periods separating the split runs, i can't think of why it would create a problem

In conclusion, if you only have a very small number of runs, it might be worth considering, but I probably wouldn't.