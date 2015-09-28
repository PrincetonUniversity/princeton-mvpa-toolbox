# Subversion Repository Access #
Subversion (also known as SVN) is a version control system. Put simply, it allows us to keep track of all the changes that have ever been made to files in the MVPA toolbox, and makes it easy for multiple people to collaborate and synchronize with each other's changes.

If you want to access the latest version of the MVPA toolbox scripts (which might not have made their way into an official release), then you can grab the latest version directly from Subversion.



# Path #
  * For those who have already know how to use Subversion or who would simply like to browse the source inside your web browser the following link will take you where you need to go:  http://princeton-mvpa-toolbox.googlecode.com/svn/trunk/

  * This link provides read only access to the public area of the MVPA archive.

  * For those with no knowledge of how Subversion works, the following is a quick rundown of the options available to you and how to use the most well supported of those options (specifically the command line.)

# Tutorial #
Subversion is used to manage the distribution of the MVPA code base among the developers inside Princeton. The main MVPA toolbox scripts are publicly accessible to make it easier for everyone to access the most up-to-date version ofthings.  Every so often, when we've made a series of important changes and we're confident that things are working perfectly, we'll make a copy of the current state of things and call it an official new release. As new program pieces are made public they will be placed in here for consumption by others, so please remember to update your local copy every now and then.

You can find out more about Subversion here:

http://svnbook.red-bean.com/en/1.1/ch01.html

For this tutorial we will assume you are using the command-line version of the SVN tools. There are also GUI tools (such as TortoiseSVN) which work in a very similar fashion.

## Step One - Setup SVN ##
Install the Subversion client on your computer - links to the installers can be found here: http://subversion.tigris.org/project_packages.html

### Linux ###
If you are using a linux machine, most software repositories have an SVN build in them that you can download (e.g. 'apt-get subversion' for Debian-based distributions).

### Mac OSX ###
There is a universal binary installer on the page listed above as well as a Fink installer that can be used. N.B. When we last tried this, the Fink version didn't seem to include SSL support (which you'll need). If anyone has any recommendations about the best Mac client to use, we'd love to hear them.
More recently an svn install was included with the latest version of OSX (10.5).  This bring you up to svn version 1.4.4 which should be more than adequate for accessing the MVPA repository.  You may have to install the developer tools to get access to this, but those are available on the OSX install disk.

### Windows ###
TortoiseSVN provides a very nice GUI client, or you can use the link above to get the command-line version from the Subversion project site.

## Step Two - Get Code ##
Once you have installed a Subversion client, open a terminal window to operate within. In MacOSX, run Terminal, and in Windows you can simple type **cmd** into the run box of the Start menu.

Now you must navigate to wherever you would like the MVPA code base to be downloaded into.  This is typically done with a _cd_ command.  This command is ubiquitous across the three platforms listed above. We recommend you check out the working copy to an new/empty directory. To checkout the repository into the current directory type:

```
svn checkout http://princeton-mvpa-toolbox.googlecode.com/svn/trunk/
```

This will begin checking out the repository copy, you will see a flurry of files zip past your screen.

## Step Three - Add to path ##
Now that you have all these files on your hard disk, you need to add them to your path (so that you can call those functions without having to be in their directory). We provide instructions for how to do this in the [setup documentation](Setup.md). The only complication is that we've tidied things up a little by distributing the .m files among a few subdirectories. You could add each of these to your path one by one, but we've added a little functionality to make this easier for you. Now, just add the main 'mvpa' directory to your path, and run 'mvpa\_add\_paths.m', and it will do the rest. In other words, the lines in your startup.m should look like this:

```

addpath /path/to/mvpa

mvpa_add_paths;

```

Restart matlab, and then try something like 'help tutorial\_easy', to check that everything is as it should be.

N.B. make sure to remove the old path from your startup.m, otherwise matlab might continue to use the old version of the scripts instead of the fresh new version you just checked out of the Subversion repository.

## Step Four - Update Code ##

If at anytime you would like to update the code to the newest most bug free release you can run

```
svn update
```

in the same folder you ran the check out in originally.  It is recommended that you do this after the first check out as well to make sure you have no loose ends.

Subversion is designed for multiple people to synchronize their changes into a single common repository. At the moment, public access is read-only, so you don't have to worry about any of your changes affecting the main repository. If you'd like to submit changes, we'd be very happy to receive them as patches.

If these instructions are unclear, please let us know.