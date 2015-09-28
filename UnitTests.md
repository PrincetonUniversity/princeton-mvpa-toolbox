# Unit Testing in MVPA #

Unit testing in MVPA has been historically a haphazard affair but as part of the move to google code we would like to correct that as well as we can going forward.

Instead of developing with the 'Cell' based testing system of the integrated matlab script editor.  Utilizing it requires both a huge difficulty curve and it lacks the capacity to publish those cell tests, making it not particularly useful for distribution purposes.

A bare-bones unit testing framework is being utilized in lieu of the cell system and is fairly straight forward to use.  If you would like to review the currently available tests you can explore the in the [tests section of the source code](http://code.google.com/p/princeton-mvpa-toolbox/source/browse/trunk#trunk/tests).

For more information check out [how to run the individual unit tests](UnitTestUsage.md) or our article on [writing your own tests](UnitTestCreation.md).