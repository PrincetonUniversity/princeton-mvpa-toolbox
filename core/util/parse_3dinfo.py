#!/usr/bin/env python

"""
If given 1 input argument (FILEN), lists all the sub-BRIKs in that file.

If given 2 input arguments (FILEN, SUBBRIKNAME), returns the zero-indexed
BRIK number for that sub-brik.

e.g.

  > greg% python /path/to/parse_3dinfo.py my_bucket+orig
  Full_Fstat
  cat2_conv_c1#0_Coef
  cat2_conv_c1#0_Tstat
  ...
  statmap_3dDeconvolve_GLT_Fstat
  
  OR
  
  > greg% python /path/to/parse_3dinfo.py my_bucket+orig 'cat2_conv_c1#0_Coef'
  1
  
  > greg% python /path/to/parse_3dinfo.py my_bucket+orig 'nonexistent_brik'
  [no output]
  
It runs a simple regular expression to extract the brik numbers and
names from 3dinfo, e.g.:

  -- At sub-brick #11 'statmap_3dDeconvolve_GLT_Fstat' datum type is short: ...
 
  -> 11, 'statmap_3dDeconvolve_GLT_Fstat'

N.B. I'm assuming that your sub-brik names consist only of
non-whitespace characters, e.g. they don't have spaces or tabs. I'm
not sure if AFNI even allows whitespace in sub-brik names - but you'll
have to tweak the main re.search() regular expression if you need to
find them.
"""

import os, sys, re, tempfile, pdb


############################################################
def create_name2num(filen):
    """
    Creates a dictionary of sub-brik names -> nums (zero-indexed) by
    calling 3dinfo on the BRIK in FILEN, and parsing its output.
    """

    # create a temporary file into which we can write the output from
    # 3DINFO. this is easier than being clever about piping the system process
    tfile = tempfile.NamedTemporaryFile('w')    
    # we want to write both STDOUT and STDERR from 3dinfo so that when
    # we're done, all we print to STDOUT is the number of the SUBBRIKNAME,
    # hence the weird >& redirect. see
    # http://tomecat.com/jeffy/tttt/cshredir.html
    cmd = '3dinfo -verb %s >& %s' % (filen,tfile.name)
    os.system(cmd)
    txt = open(tfile.name,'r').read()
    lines = txt.split('\n')
    tfile.close()
    # TFILE gets automatically deleted by close() in python 2.6+, but
    # let's be sure
    if os.path.exists(tfile.name): delete(tfile.name)
 
    name2num = {}
    for line in lines:
        matches = re.search("At sub-brick #(\d+) '(\S*)' datum", line)
        if matches:
            num, name = matches.groups()
            num = int(num)
            # sanity-check that we haven't already found a sub-brik like
            # this before
            assert not name2num.has_key(name)
            assert not num in name2num.values()
            name2num[name] = num
    
    return name2num
    

############################################################
if __name__=="__main__":

    args = sys.argv[1:]
    if len(args)==0 or len(args)>2:
        print 'USAGE:\n%s\n' % (__doc__.strip())
        sys.exit(0)    
    filen = args[0]
    if len(args)==2: subbrikname = args[1]
    else: subbrikname = None
    
    name2num = create_name2num(filen)

    if subbrikname:
        # print the NUM for the subbrik we're interested in, if we found
        # it
        if name2num.has_key(subbrikname):
            print name2num[subbrikname]
    else:
        # no subbrik specified, so just print them all (sorted by NUM)
        nums_names = name2num.items()
        nums_names.sort(key=lambda x : x[1])
        for nn in nums_names: print '%s' % nn[0]
    

