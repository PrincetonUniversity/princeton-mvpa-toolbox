function smp_map_data = bv_createsmpmap(vmp,reco_srf)
% function smp_map_data = bv_createsmpmap(vmp,reco_srf)
%
% Given a vmp (stats in the volume) and a reconstructed surface, create an
% smp stat map by sampling the stat volume at the vertices.
%
% History:
%
% 2004.03.10    bds     wrote it
% 2004.06.10    bds     updated for bv2mat package

% finds nearest integer coordinates to be used as indices into VMP

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

numV = length(reco_srf.VertexX);
v=1:numV;
x = round(reco_srf.VertexX(v)-vmp.XStart);
y = round(reco_srf.VertexY(v)-vmp.YStart);
z = round(reco_srf.VertexZ(v)-vmp.ZStart);

h = waitbar(0, sprintf('Reconstructing SMP for %d vertices...', numV));
updateChunk = round(numV/100);
smp_map_data = zeros(numV,1);
for i=v
    if ~mod(i,updateChunk)
        waitbar(i/numV,h)
    end
    smp_map_data(i) = vmp.Map.data(x(i),y(i),z(i));
end
close(h);
