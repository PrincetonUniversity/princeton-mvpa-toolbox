function vmp = bv_readvmp(fname)
% vmp = bv_readvmp(fname)
%
% :description
%
% Reads in a version 1 (BV 2000) or version 2 (BrainVoyager QX) VMP file.
%
% :inputs
%
% fname             file to read, e.g. 'myvolstats.vmp'
%
% :outputs
%
% vmp               vmp structure. List this function to see the field
%                   names.
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

fid = platform_fopen(fname,'r');

vmp.VersionNumber = fread(fid, 1, 'int16');
if vmp.VersionNumber > 2
    error('Can only read version 1 or 2 files');
end
if vmp.VersionNumber == 2
    intSize = 'int32';
else
    intSize = 'int16';
end

vmp.NrOfMaps = fread(fid, 1, intSize);
vmp.MapType = fread(fid, 1, intSize);
vmp.NrOfLags = fread(fid, 1, intSize);

if vmp.VersionNumber == 2
    for m=1:vmp.NrOfMaps
        vmp.Map(m) = bv_readstathdr(fid);
    end
else
    vmp.Map(1).ClusterSize = fread(fid, 1, intSize);
    vmp.Map(1).StatThreshCritValue = fread(fid, 1, 'float32');
    vmp.Map(1).StatColThreshMaxValue = fread(fid, 1, 'float32');
    vmp.Map(1).df(1:2) = fread(fid, 2, intSize);
    vmp.Map(1).name = read_str(fid);
end

vmp.VMRDimXYZ = fread(fid, 3, intSize);
vmp.XStart = fread(fid, 1, intSize);
vmp.XEnd = fread(fid, 1, intSize);
vmp.YStart = fread(fid, 1, intSize);
vmp.YEnd = fread(fid, 1, intSize);
vmp.ZStart = fread(fid, 1, intSize);
vmp.ZEnd = fread(fid, 1, intSize);
vmp.Resolution = fread(fid, 1, intSize);

vmp_data_dims = [   (vmp.XEnd - vmp.XStart + 1) / vmp.Resolution ...
                    (vmp.YEnd - vmp.YStart + 1) / vmp.Resolution ...
                    (vmp.ZEnd - vmp.ZStart + 1) / vmp.Resolution];

% now read data. Loops, outer to inner, are nmaps,z,y,x
for m=1:vmp.NrOfMaps
    vmp.Map(m).data = zeros(vmp_data_dims(1),vmp_data_dims(2),vmp_data_dims(3));
    for z=1:vmp_data_dims(3)
        vmp.Map(m).data(:,:,z) = fread(fid,[vmp_data_dims(1),vmp_data_dims(2)],'float32');
    end
end

fclose(fid);
