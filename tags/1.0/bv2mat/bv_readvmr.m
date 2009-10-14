function vmr = bv_readvmr(fname)
% vmr = bv_readvmr(fname)
%
% :description
%
% Reads in a version 0, 1 or 2 (BrainVoyager 2000, QX) VMR file.
% Does not read in the positioning data added to the end of the file
% in QX (version 2)
%
% :inputs
%
% fname             file to read, e.g. 'myproj.vmr'
%
% :outputs
%
% vmr               vmr structure. List this function to see the field
%                   names.
%
% :history
%
% 2004.04.16	Ben Singer  Edited slightly a version received from Sylvain.
%                           Probably originally written by Jens Schwarzbach
%                           in August 2002.  
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

fid = platform_fopen(fname,'r');

vmr.DimX = fread(fid, 1, 'uint16');
if vmr.DimX == 0
    % version 0, skip first two shorts
    dummy = fread(fid,1,'uint16');
    vmr.DimX = fread(fid,1,'uint16');
end
vmr.DimY = fread(fid, 1, 'uint16');
vmr.DimZ = fread(fid, 1, 'uint16');

vmr.Map = reshape(fread(fid,vmr.DimX*vmr.DimY*vmr.DimZ,'ubit8'),vmr.DimX,vmr.DimY,vmr.DimZ);

fclose(fid);
