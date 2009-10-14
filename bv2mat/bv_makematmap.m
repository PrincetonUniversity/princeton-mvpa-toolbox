function matmap = bv_makematmap(flat_srf,smp_map_data)
% matmap = bv_makematmap(flat_srf,smp_map_data)
%
% :description
%
% Creates a 2D matrix containing a map from an SMP file.
% An SMP contains its map in a 1D vector, so making a 2D
% matrix requires information about the 2D position of
% each value in the flat map. This is provided by a flattened
% surface in an SRF file, which contains three 1D vectors
% containing the corresponding X,Y, and Z coordinates.
% In a flat surface Z is constant, so we use the X and Y
% positions only.
% 
% :example usage
%
% flat_srf = bv_readsrf('myflatsurface.srf',1);
% smp = bv_readsmp('mysurfacemap.smp');
% matmap = bv_makematmap(flat_srf,smp.map(1).data);
%
% :inputs
%
% flat_srf          A srf structure read in from a flattened SRF file.
%                   Use srf = bv_readsrf('myflatsurface.srf',1) to read it
%                   in.
% smp_map_data      A map from a smp structure, read in from an SMP file.
%                   Use smp = bv_readsmp('mysurfacemap.smp') to read it in,
%                   and pass in smp.map(1).data-- this will use the first
%                   map in the smp.
%
% :outputs
%
% matmap            A 2D matrix that samples the SMP values on a regular
%                   grid that span the range of coordinates, with each
%                   entry in the matrix incrementing by a value of 1.0
%
% :history
%
% 2004.03.12    Ben Singer  Wrote it
% 2004.03.15    Ben Singer  Handle negative vertices, removed subsampling

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

% figure range of vertex values
startX = min(flat_srf.VertexX);
endX = max(flat_srf.VertexX);
startY = min(flat_srf.VertexY);
endY = max(flat_srf.VertexY);

% make a version of the vertices so that they are valid indices (positive integers)
vX = round(flat_srf.VertexX - startX) + 1;
vY = round(flat_srf.VertexY - startY) + 1;
lastX = round(endX - startX) + 1;
lastY = round(endY - startY) + 1;

% build a 2D lookup table of smp_map_data. Rounds to integer vertex coordinates.
% these usually don't range much beyond 256, so safe.
matmap = zeros(lastY,lastX);
for v = 1:length(smp_map_data)
    matmap(vY(v),vX(v)) = smp_map_data(v);
end
