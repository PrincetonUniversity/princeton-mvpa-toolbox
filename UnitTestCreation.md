# Writing Unit Tests #

There are a few minimal requirements to setting up a new test from the standpoint of the framework and execution in a general sense.

## Function Declaration ##

The function declaration has to include returns for the structures _errs_ and _warns_.  These structures are arrays of strings utilized for storing messages of each type from the unit test itself.

```
function [errs warns] = unit_test(varargin)
```

## Main Function Structure ##

Declare local copies of the _errs_ and _warns_ as follows.

```
errs = {};
warns = {};
```

This allows you to simply append to the end of the list with sub-functions through simple string returns.

```
[errs{end+1} warns{end+1}] = test_case_x(args);
```

After this has been setup, call each test case in a manner similar to the above code block.

## Test Case Function Structure ##

Test cases are discrete blocks of code that test a single range of functionality or error handling.  Instead of writing a single test that would cover all aspects of the function it's best to write micro tests that cover a particular behavior or edge case.  These test cases can also cover failure conditions, in which case the errs/warns should be filled only if the function did not fail as intended.

The rule of thumb is returning an empty _errs_ and _warns_ structure is good, anything returned should be inherently bad.