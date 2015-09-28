# Using MD5 Checksums #

MD5: A software algorithm used to “fingerprint” a file or contents of a disk; used to verify the integrity of data. In forensic analysis it is typically used to verify that an acquired image of suspect data was not altered during the process of imaging.



## Our Use ##

> Currently we only provide MD5 sums for the two large datasets provided as secondary downloads to the main scripts and the SPM scripts.  These checksums can be used to verify that you have recieved a _good_ version of the fairly large files.

## Theory and Usage ##

> MD5 sums are passed into a program for checking to make sure that the calculated md5 sum for a given file equals the sum provided by the files source.  This verifies it's integrity.

> We recommend you do this on a MacOSX or Linux box as the md5sum program is available on both platforms.  Microsoft does provide an MD5 program but it is unclear whether this program will work with the sums we have provided due to differences in default behavior.

> For our purposes simply place the file `md5mvpa.txt` in the same folder as the data file(s) you wish to verify.  These should be the ` .tar.gz ` versions of the files, so you know that the files are good before unpacking them.  Then run the command `md5sum -c md5mvps.txt` in a terminal window at that directory location.  If there is nothing wrong with the files, after a long pause the program will return without any feedback.  If there is a problem with one of the files then it will inform you as to which file is faulty.  If you don't have one of the files it checks in the folder it will simply note that it can't open this file, these errors can be safely ignored as the software can't check data for something that doesn't exist.