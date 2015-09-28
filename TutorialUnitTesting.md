# MVPA Unit Test Framework. #

The MVPA unit test framework is fairly simple and straightforward. It allows you to:

  * define the expected behavior of your functions, and confirm that they do in fact behave in this way

  * check that your function fails when it's supposed to fail

  * allows you to automatically run your entire test suite in a big batch, returning simple statistics over all the tests

If you prefer reading code to words, then you can get a pretty clear sense of what we have in mind from looking at our example unit test, ['unit\_template.m'](http://code.google.com/p/princeton-mvpa-toolbox/source/browse/trunk/tests/unit_template.m).

A note for those familiar with extensive test frameworks in other languages: we have not attempted to implement the full functionality available in dedicated unit tests suits (such as [JUnit](http://www.junit.org/) and [PyUnit](http://diveintopython.org/unit_testing/romantest.html)). Instead, we define some simple idioms that make it easy to construct the equivalent of assertEqual and assertFail statements in Matlab, and then leave it at that.

At the bottom, we provide links to a number of articles that expouse the many virtues of unit testing.


## File Format ##

Only thing to note here is that all unit tests filenames are formatted the same way.  They are simply 'unit_<function name to be tested>.m'.  This will allow the unit test to be included in functions that simply call all of the unit tests available._


## The function definition ##

Some simple rules should be followed when declaring a unit test function.

1. The unit test should take no required arguments, i.e. it should be self contained. It can take in optional arguments, which can be useful for running tests interactively.

> There are special cases where this can be tricky. For instance, if your test relies on reading in sample data files then you might have to specify that the test needs to be run in a particular directory, or make use of optional or global variables.

2. The unit test should return two cell arrays of strings, usually called 'errs' and 'warns'. Each string contains a brief description of the test that failed. The 'errs' are critical errors (where the function does not do what it is supposed to do) and 'warns' holds less important warnings (e.g. where the test could not be run because of a missing dependency).


## Main Code ##

Adding information to the errors and warning messages is fairly simple as they are cell arrays.  For example, to extend the 'errs' cell array:

```
errs{end+1}="error text";
```

The main code of a unit test is fairly simple and straightforward and can be broken up into three basic areas of testing.

> Confirmation tests:: Tests designed to make sure the actual behavior of the function matches its expected behavior. For instance, a test of the pretend squaring function, 'sqr', might expect that sqr(5) will return 25. If this isn't the case, then we would extend the 'errs' cell array with a description such as 'Basic test with input 5', which would then be displayed when we run the whole test suite.

```
desired = 25;
actual = sqr(5);
if desired ~= actual
  errs{end+1} = 'Basic test with input 5';
end
```

> Failure tests:: Tests utilizing the Matlab ['try/catch'](http://www.mathworks.com/access/helpdesk/help/techdoc/index.html?/access/helpdesk/help/techdoc/matlab_prog/bq9l46c-1.html&http://www.mathworks.com/access/helpdesk/help/techdoc/ref/catch.html#bq9ta2g-1) code structure to confirm that your function fails when it's supposed to fail. For instance, if your function requires at least one argument, then it should raise some kind of exception if called with no arguments. One of your failure tests might call the function with zero arguments, and check that it does indeed fail under these circumstances - otherwise, add a message to the 'errs' cell array.

```
try
  sqr()
  errs{end+1} = 'Should fail with zero args';
end
```

> If `sqr()` fails, then Matlab will jump out of the 'try' block, and the `errs{end+1} ` line will never get run. However, if the function runs without raising an exception, we extend the 'errs' cell array with the error message.

> Dependency tests:: These tests simply check to make sure the dependencies for your functions are available, populate the 'warns' cell array if they are not. For instance, if your function requires the Statistics Toolbox to run, then you'll get a warning rather than an error if the Statistics Toolbox is missing.

```
if ~exist('tutorial_easy')
  warns{end+1} = 'MVPA toolbox is not in the path - won''t be able to run remaining tests';
  return
end
```

> If the dependency being tested here was critical for your
> tests, you might as well just exit now, and avoid the
> inevitable errors that will ensue.

## Finally ##

Finally, there's a function in the mvpa/tests directory called ['run\_unit\_tests.m'](http://code.google.com/p/princeton-mvpa-toolbox/source/browse/trunk/tests/run_unit_tests.m) that runs all the tests in the 'mvpa/tests' directory in sequence, keeping track of which tests fail. This gives us confidence that changes we've made aren't inadvertently breaking things.

As we would love to be able to confidently incorporate the works of contributors as well, we are publishing these guidelines so that contributors can have their software tested with the rest of the MVPA package.

Now would be a good time to have a look at our example unit test, ['unit\_template.m'](http://code.google.com/p/princeton-mvpa-toolbox/source/browse/trunk/tests/unit_template.m). Modifying that to test one of your own functions is the simplest way to get started.

Good luck and happy testing!


## Articles on unit testing ##

  * [Why unit tests are good](http://www.extremeprogramming.org/rules/unittests.html)

  * [Empirical evidence that test-driven programming is effective](http://morenews.blogspot.com/2007/08/tdd-results-are-in.html)

  * [Some testing theory](http://en.wikipedia.org/wiki/Unit_testing)


---


CategoryTutorials