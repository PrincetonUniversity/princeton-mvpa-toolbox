# Advanced Manual #

## Creating custom functions ##

It is very easy to override the toolbox's default functions with your own custom-created function that the main toolbox control functions can call when appropriate. For instance, if you don't want to use the default backpropagation classifier, or the default ANOVA statmap generator, you can drop your own functions in instead, and the toolbox's no-peeking cross-validation control functions will use your custom functions instead at the appropriate times.

At the moment, there are various places where you can substitute your own functions ' click on the links in the list below to skip to the section where the specific details for each are described.

If you do create a custom function and you think others might benefit from it, we'd really like to [hear from you](#_Contact_details.md) so that we can incorporate it into future releases of the toolbox.


### Places that can call custom function ###

  * [statmap generation](http://code.google.com/p/princeton-mvpa-toolbox/source/browse/trunk/core/preproc/feature_select.m) ' _feature\_selection.m_ and _peek\_feature\_selection.m_ can take optional _statmap\_funct_ and _statmap\_arg_ arguments
  * [classifier training](http://code.google.com/p/princeton-mvpa-toolbox/source/browse/trunk/core/learn/cross_validation.m) ' _cross\_validation.m_ can take an optional _train\_funct_ function name string
  * [classifier test](http://code.google.com/p/princeton-mvpa-toolbox/source/browse/trunk/core/learn/cross_validation.m) ' _cross\_validation.m_ can take an optional _test\_funct_ function name string
  * [classifier performance metrics](http://code.google.com/p/princeton-mvpa-toolbox/source/browse/trunk/core/learn/cross_validation.m) ' _cross\_validation.m_ can take an optional _perfmet\_functs_ cell array of performance metric function name strings


### Requirements for custom functions that modify the _subj_ structure ###

Any custom functions that modify the _subj_ structure (usually by creating a new object) should fulfil the following requirements, if they're going to be well-behaved toolbox citizens:

· take in a _subj_ structure as their first argument

· return the modified _subj_ structure as their first output argument

· if the custom function creates a new _subj_ structure object, you should add a line to the help comments that says 'Adds the following objects:' and a list of the objects/groups that get created

· if the custom function creates a new _subj_ structure object, you should display something like:
```
sprintf('Created %s called %s',objtype,objname)
```
  * should call the [add\_created.m](http://code.google.com/p/princeton-mvpa-toolbox/source/browse/trunk/core/subj/add_created.m) with fields for the name of the function and any arguments it takes
  * should call [add\_history.m](http://code.google.com/p/princeton-mvpa-toolbox/source/browse/trunk/core/subj/add_history.m) to add a line describing themselves to their own freetext history narrative
  * try and do some error-checking on the inputs, if there are any assumptions that the function makes, to help future users avoid making hard-to-debug booboos