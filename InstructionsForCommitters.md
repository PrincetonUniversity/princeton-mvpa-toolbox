# Instructions for committing changes to the SVN development version #

If you're on the list of project committers, then you can edit, add or delete code, and commit your changes to the main SVN development version. You can also edit the wiki pages to update them with relevant tweaks from the code.

You can see the list of committers in the right-hand sidebar of the main page:

http://code.google.com/p/princeton-mvpa-toolbox/

## New Functionality and Utility Scripts ##

Adding new functionality is fairly straightforward.  First, make sure you're inserting it into an appropriate location in the overall code structure.  It would generally be more appropriate to include these additions in the 'contrib' folder unless you're performing core development.  If there are multiple related files involved, create a sub-folder under 'contrib'.

If you're adding any new functionality, please please include a series of [unit tests](UnitTests.md).  Other scientists are going to be trusting and depending on your code, and writing unit tests is one of the very best ways to be sure things are working correctly.  Try and confirm all the major behaviors of the function (and any discernible edge cases), think about ways that the options might interact weirdly etc. This also makes it much easier for others to modify/extend your functions later and know that things are still working correctly.

Do also make sure to include a full description at the top of the file to describe what it's for, how it should work, example usage, a little about the variables it takes in and returns, citations to relevant papers, and anything else that would help future users. See e.g. the comments at the top for:

http://code.google.com/p/princeton-mvpa-toolbox/source/browse/trunk/core/learn/train_bp.m

http://code.google.com/p/princeton-mvpa-toolbox/source/browse/trunk/contrib/learn/optimal_penalty_search.m

## Modification of Existing Scripts ##

Code updates and modifications should be handled with a larger degree of caution.

A few critical ground rules:

- DO be conservative if you're changing the 'core' code. Is there a way to add your functionality without changing any of the main functions?

- DON'T break anything! If the function already has unit tests, check they pass before and after your changes.

- DON'T change the behavior of an existing function. Instead, add an optional argument that defaults to the previous behavior, so that no one depending on the function will have the rug pulled out from under their feet without their knowledge.

- DO get at least one other person to check over your code, and let the mailing list know

It helps sometimes to document your modifications with a name and date at the top of the code beneath the function description (especially if you're not the committer).

## Code Review ##

[We're experimenting with the Google Code functionality for 'code reviews', where someone else can look over your changes. This section describes how that works.]

To request a code review before committing to the main development trunk, you'd have to do your work in the `/branches/` area instead of the 'trunk'. In the code review you should include the final destination of that file and anything that's relevant to the review should be noted in the request area (basically, fill out the template).

There are a large number of code reviewing tips located at the [central google code wiki](http://code.google.com/p/support/wiki/CodeReviews).  These provide information on the best way to review code, how to watch a revision for code reviews and a variety of other useful tips like entering code review requests during your SVN commit to the /branches/ directory area.

## New releases ##

Every so often, we'll take the latest development version, and sanction it as an official release (usually after we've added major new functionality, or if it feels as though enough small changes have accumulated)

## Documentation ##

Do please improve any of the wiki documentation, especially if you add new stuff.  Also make sure to put the unit tests in place.