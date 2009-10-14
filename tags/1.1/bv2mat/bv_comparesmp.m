% bv_comparesmp
%
% Reads VMP, reconstructed SRF, and SMP that are output by BrainVoyager
% and computes a new smp stat map using the SRF vertices in the VMP.
% To see if the mapping between volume and surface is understood.
%
% History:
%
% 2004.03.12    bds     wrote it
% 2004.06.10    bds     version for Frank Tong's lab, updated to use
%                       current bv2mat scripts and sample data

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

% Parameters
folder = '';
reco_fname = 'CG2_TAL_LH_RECO.srf';
flat_fname = 'CG2_TAL_LH_INFL_FLAT.srf';
vmp_fname = 'cg2_3DT1FL_SINC4_TAL_RvsL.vmp';
smp_fname = 'CG2_TAL_LH_INFL_FLAT_RvsL.smp';
figScale = 2;

% Load data created in BrainVoyager
reco_srf = bv_readsrf([folder,reco_fname],1);
flat_srf = bv_readsrf([folder,flat_fname],1);
vmp = bv_readvmp([folder,vmp_fname]);
smp = bv_readsmp([folder,smp_fname]);

% Create our own SMP map data the way we think BrainVoyager does
smp_map_data = bv_createsmpmap(vmp,reco_srf);

% Create a 2D matrix from BrainVoyager's and our SMP stat map
statMatrix_bv = bv_makematmap(flat_srf,smp.map.data);
statMatrix_our = bv_makematmap(flat_srf,smp_map_data);

% Compare visually via grayscale figures
close all;
[h1,theImage1] = MakeGrayImageFigureForMatrix(statMatrix_bv,'BV''s SMP',figScale);
[h2,theImage2] = MakeGrayImageFigureForMatrix(statMatrix_our,'Our SMP',figScale);
disp('figures will be compared 10 times...');
for i=1:10
    figure(h1);
    pause(1);
    figure(h2);
    pause(1);
end