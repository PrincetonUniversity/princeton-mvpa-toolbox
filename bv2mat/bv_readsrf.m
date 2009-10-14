function srf = bv_readsrf(fname,upto_neighbors)
% srf = bv_readsrf(fname,upto_neighbors)
%
% :description
%
% Reads in a version 3 (BrainVoyager 2000 4.4, QX) SRF file.
%
% :inputs
%
% fname             file to read, e.g. 'mysurface.srf'
% upto_neighbors    set to 1 if you only want to read in vertices, normals,
%                   and mesh color, skipping time-consuming nearest
%                   neighbor reading operations. [optional, default is 0]
%
% :outputs
%
% srf               srf structure. List this function to see the field
%                   names.
%
% :history
%
% 2004.03.05	Ben Singer  Wrote it, based on scripts from Sylvain Takerkart and
%                           Jens Schwarzbach
% 2004.04.28    Ben Singer  Prepared for release to CSBMB community
% 2004.06.10    Ben Singer  Seems to work with SRF version 4, at least for
%                           vertices ('upto_neighbors')
% 2004.06.11	Ben Singer  Changed "||" to "|" in srf version conditional

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

if nargin < 2
    upto_neighbors = 0;
end

fid = platform_fopen(fname,'r');

srf.VersionNumber = fread(fid, 1, 'float32');
if srf.VersionNumber < 3 | srf.VersionNumber > 4
    warn('Only tested with version 3 or 4 SRF files');
end

srf.Reserved = fread(fid, 1, 'int32');
srf.NrOfVertices = fread(fid, 1, 'int32');
srf.NrOfTriangles = fread(fid, 1, 'int32');
srf.MeshCenterXYZ = fread(fid, 3, 'float32');
srf.VertexX = fread(fid, srf.NrOfVertices, 'float32');
srf.VertexY = fread(fid, srf.NrOfVertices, 'float32');
srf.VertexZ = fread(fid, srf.NrOfVertices, 'float32');
srf.NormalX = fread(fid, srf.NrOfVertices, 'float32');
srf.NormalY = fread(fid, srf.NrOfVertices, 'float32');
srf.NormalZ = fread(fid, srf.NrOfVertices, 'float32');
srf.RGBAConvex = fread(fid, 4, 'float32');
srf.RGBAConcave = fread(fid, 4, 'float32');
srf.MeshColor = fread(fid, srf.NrOfVertices, 'int32');

if upto_neighbors
    return;
end

h = waitbar(0, sprintf('Reading Neighbours for %d vertices...', srf.NrOfVertices));
srf.Vertex(srf.NrOfVertices).NumNeighbours = 0;
srf.Vertex(srf.NrOfVertices).NumNeighbours = [];
for i = 1:srf.NrOfVertices
    waitbar(i/srf.NrOfVertices,h)
    srf.Vertex(i).NumNeighbours = fread(fid, 1, 'int32');
    srf.Vertex(i).Neighbours = fread(fid, srf.Vertex(i).NumNeighbours, 'int32');
end
srf.Triangles = fread(fid, 3*srf.NrOfTriangles, 'int32');
srf.NrOfTriangleStripElements = fread(fid, 1, 'int32');
srf.StripElements =  fread(fid, srf.NrOfTriangleStripElements, 'int32');

fclose(fid);
