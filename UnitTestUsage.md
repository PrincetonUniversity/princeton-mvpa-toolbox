# Executing the Unit Tests #

The unit tests in general do not require any exterior information in order to execute and can simply be run while the MVPA package is in your matlab path.  This being said a subset of the functions do require outside data depending on what you would like to test.

Specifically you will need outside data to run the unit tests for the afni and spm file handler sub-systems.  However this data is the same required to execute the tutorials (and the unit tests actually utilize the tutorial functions in some cases), so you kill two birds with one stone.

If the unit test does not require external data you can execute it from anywhere in your folder structure as long as the test is in your path.  If the test requires a specific data set, that data-set must be in your current working directory for the test to work.