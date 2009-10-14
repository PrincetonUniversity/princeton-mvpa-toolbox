function vtc = bv_readvtc(fname)
% vtc = bv_readvtc(fname)
%
% :description
%
% Reads in a version 1 or 2 BrainVoyager VTC file.
%
% :inputs
%
% fname             file to read, e.g. 'mytimecourse.vtc'
%
% :outputs
%
% vtc               vtc structure. List this function to see the field
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

vtc.VersionNumber = fread(fid, 1, 'int16');
vtc.FMRName = read_str(fid);
vtc.PRTName = read_str(fid);
vtc.NrOfVolumes = fread(fid, 1, 'int16');
vtc.Resolution = fread(fid, 1, 'int16');
vtc.XStart = fread(fid, 1, 'int16');
vtc.XEnd = fread(fid, 1, 'int16');
vtc.YStart = fread(fid, 1, 'int16');
vtc.YEnd = fread(fid, 1, 'int16');
vtc.ZStart = fread(fid, 1, 'int16');
vtc.ZEnd = fread(fid, 1, 'int16');

if ( vtc.VersionNumber == 2 )
    vtc.HemodynamicDelay = fread(fid, 1, 'int16');
    vtc.TR = fread(fid, 1, 'float32');
    vtc.HDR_Delta = fread(fid, 1, 'float32');
    vtc.HDR_Tau = fread(fid, 1, 'float32');
    vtc.SegmentSize = fread(fid, 1, 'int16');
    vtc.SegmentOffset = fread(fid, 1, 'int16');
end;

DimZ = (vtc.ZEnd - vtc.ZStart) / vtc.Resolution;
DimY = (vtc.YEnd - vtc.YStart) / vtc.Resolution;
DimX = (vtc.XEnd - vtc.XStart) / vtc.Resolution;
DimT = vtc.NrOfVolumes;

vtc.data = reshape(fread(fid,DimX*DimY*DimZ*DimT,'int16'),DimT,DimX,DimY,DimZ);

fclose(fid);
