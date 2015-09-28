# Administrator Notes #

This is just a catchall for administrative procedures.

## Publishing New Releases ##

This is a multi step process that starts by selecting the specific revision the release will be based on.  If it is going to include a call for contributions from the commiters, a time window should be established for when commits are due by for the publishing of the new release.  At that point, select the latest revision on that date and use that as the base.

  1. Check out the revision into a new directory
  1. Use the 'SVN Export' function to create a third directory that is a copy without all the hidden '.svn' folders
  1. Using a graphical log browser (tortoiseSVN's has proven very useful) display all the file changes and log notes and copy them into a text file.  This will create the basis for the change log
  1. At this point it requires a bit more inspection, the 'diff' function from the source browser will help.  If a file is modified instead of being added and it's not noted in the log what the change was, that change should be inspected and noted quickly for it's effect on the code's behavior
  1. Save this text file as `CHANGELOG.TXT` inside the base of the folder of the SVN export.
  1. Change the base folder of the SVN Export to be MVPA-x.xx where x.xx is the current revision number
  1. Package this folder up in a .tar.gz file and publish it to the [downloads area](http://code.google.com/p/princeton-mvpa-toolbox/downloads/list)
  1. Update the links to the current revision in the [Downloads](Downloads.md) area to point to the latest .tar.gz file
  1. Announce the new release to the list, attach a copy of the change log to the email announcement