function fid = platform_fopen(fname,perm)
% fid = platform_fopen(fname,perm)
%
% :description
%
% A utility function that opens a binary file across multiple
% platforms. On the Mac and SGI, BrainVoyager file bytes must be swapped.
%
% :inputs
%
% fname             file to open, e.g. 'myvolstats.vmp'
% perm              'r' for read, 'w' for write (see help fopen)
%
% :outputs
%
% fid           File id returned by fopen.
%
% :history
%
% 2004.03.05	Ben Singer  Wrote it
% 2004.04.28    Ben Singer  Prepared for release to CSBMB community
% 2004.06.11	Ben Singer	Changed "||" to "|" in platform conditional

% License:
%=====================================================================
%
% This is part of the Princeton MVPA toolbox, released under
% the GPL. See http://www.csbmb.princeton.edu/mvpa for more
% information.
% 
% The Princeton MVPA toolbox is available free and
% unsupported to those who might find it useful. We do not
% take any responsibility whatsoever for any problems that
% you have related to the use of the MVPA toolbox.
%
% ======================================================================

if strcmp(computer,'MAC') | strcmp(computer,'SGI')
    fid = fopen(fname,perm,'l');
else
    fid = fopen(fname,perm);
end

if -1 == fid
    fprintf('Cannot open %s\n',fname);
    error('[fopen returned -1]');
end