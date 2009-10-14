function voi = bv_readvoi(fname)
% voi = bv_readvoi(fname)
%
% :description
%
% Reads in a version 1 BrainVoyager VOI file.
%
% :inputs
%
% fname             file to read, e.g. 'myvoi.voi'
%
% :outputs
%
% voi               voi structure. List this function to see the field
%                   names.
%
% :history
%
% 2004.04.16	Ben Singer  Edited slightly a version received from Sylvain.
%                           Probably originally written by Jens Schwarzbach
%                           in August 2002.  
% 2004.04.28    Ben Singer  Prepared for release to CSBMB community

fid = platform_fopen(fname,'r');

% read File Version
while 1
    textline = fgetl(fid);
    if  size(textline,2)~=0 break, end
end
[myString,voi.FileVersion] = strread(textline,'%s%d');
if voi.FileVersion~=1
    error('ERROR: Unknown VOI file version.');
end

% read Coordinates Type
while 1
    textline = fgetl(fid);
    if  size(textline,2)~=0 break, end
end
[myString,voi.CoordsType] = strread(textline,'%s%s');
if strcmp(voi.CoordsType,'TAL')~=1
    error('ERROR: Coordinates must be in Talairach space');
end

% read number of VOIs in the file
while 1
    textline = fgetl(fid);
    if  size(textline,2)~=0 break, end
end
[myString,voi.NrOfVOIs] = strread(textline,'%s%d');

XStartVTC =	57; YStartVTC = 52; ZStartVTC = 59;
m_ACxTAL = 128; m_ACyTAL = 128; m_ACzTAL = 128;
ResolutionVTC = 3;

% loop over VOIs
for this_voi=1:voi.NrOfVOIs
    
    % read name of VOI
    while 1
        textline = fgetl(fid);
        if  size(textline,2)~=0 break, end
    end
    [myString,voi.VOIs(this_voi).NameOfVOI] = strread(textline,'%s%s');
    
    % read number of voxels
    while 1
        textline = fgetl(fid);
        if  size(textline,2)~=0 break, end
    end
    [myString,voi.VOIs(this_voi).NrOfVoxels] = strread(textline,'%s%d');
    disp(fprintf('VOI number %d contains %d voxels',this_voi,voi.VOIs(this_voi).NrOfVoxels));
    
    % loop over voxels: read their coordinates
    for this_vox = 1:voi.VOIs(this_voi).NrOfVoxels
        textline = fgetl(fid);
        [x,y,z] = strread(textline,'%d%d%d');
        voi.VOIs(this_voi).x_vmr(this_vox) = x;
        voi.VOIs(this_voi).y_vmr(this_vox) = y;
        voi.VOIs(this_voi).z_vmr(this_vox) = z;
        
%        voi.VOIs(this_voi).x_vtc(this_vox) = (-1*(z - m_ACzTAL) - XStartVTC) / ResolutionVTC;
%        voi.VOIs(this_voi).y_vtc(this_vox) = (-1*(x - m_ACxTAL) - YStartVTC) / ResolutionVTC;
%        voi.VOIs(this_voi).z_vtc(this_vox) = (-1*(y - m_ACyTAL) - ZStartVTC) / ResolutionVTC;
        
        % rainer's version
        voi.VOIs(this_voi).x_vtc(this_vox) = (m_ACxTAL - y - XStartVTC) / ResolutionVTC;
        voi.VOIs(this_voi).y_vtc(this_vox) = (m_ACyTAL - z - YStartVTC) / ResolutionVTC;
        voi.VOIs(this_voi).z_vtc(this_vox) = (m_ACzTAL - x - ZStartVTC) / ResolutionVTC;
        
    end
    
end

    

