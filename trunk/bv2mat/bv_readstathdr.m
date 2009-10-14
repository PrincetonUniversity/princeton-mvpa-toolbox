function map = bv_readstathdr(fid)
% map = bv_readstathdr(fid)
%
% :description
%
% A utility function that reads the stat map header,
% common to vmp (version 2) and smp files. Used by bv_readsmp and bv_readvmp.
%
% :inputs
%
% fid           file id of file already opened for reading
%
% :outputs
%
% map           map structure, part of SMP and VMP structures.
%               List this function to see the field names.
%
% :history
%
% 2004.03.05	Ben Singer  Wrote it, based on scripts from Sylvain Takerkart and
%                           Jens Schwarzbach
% 2004.04.28    Ben Singer  Prepared for release to CSBMB community

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

map.ClusterSize = fread(fid, 1, 'int32');
map.EnableClusterCheck = fread(fid, 1, 'int8');
map.StatThreshCritValue = fread(fid, 1, 'float32');
map.StatColThreshMaxValue = fread(fid, 1, 'float32');
map.df(1:2) = fread(fid, 2, 'int32');
map.Bonferroni = fread(fid, 1, 'int32');
map.RGBcrit = fread(fid, 3, 'uint8');
map.RGBmax = fread(fid, 3, 'uint8');
map.EnableSMPColor = fread(fid, 1, 'int8');
map.TransparentColorFactor = fread(fid, 1, 'float32');
map.name = read_str(fid);
