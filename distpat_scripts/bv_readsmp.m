function smp = bv_readsmp(fname)
% smp = bv_readsmp(fname)
%
% :description
%
% Reads in a version 2 (BV 2000) or 3 (BrainVoyager QX) SMP file.
%
% :inputs
%
% fname             file to read, e.g. 'myflatstats.smp'
%
% :outputs
%
% smp               smp structure. List this function to see the field
%                   names.
%
% :history
%
% 2004.03.05	Ben Singer  Wrote it, based on scripts from Sylvain Takerkart and
%                           Jens Schwarzbach
% 2004.04.28    Ben Singer  Prepared for release to CSBMB community

fid = platform_fopen(fname,'r');

smp.VersionNumber = fread(fid, 1, 'int16');
smp.NrOfVertices = fread(fid, 1, 'int32');
smp.NrOfMaps = fread(fid, 1, 'int16');

qx = smp.VersionNumber == 3;
if qx
    smp.FromSRF = read_str(fid);
elseif smp.VersionNumber < 2
    error('Can only read version 2 or 3 files');
end
smp.MapType = fread(fid, 1, 'int16');
smp.NrOfLags = fread(fid, 1, 'int16');
if ~qx
    smp.FromSRF = read_str(fid);
end

for m=1:smp.NrOfMaps
    smp.map(m) = bv_readstathdr(fid);
end

for m=1:smp.NrOfMaps
    smp.map(m).data = zeros(smp.NrOfVertices,1);
    smp.map(m).data = fread(fid,smp.NrOfVertices,'float32');
end

fclose(fid);
