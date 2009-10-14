function voi = bv_readvoi(fname)
% voi = bv_readvoi(fname)
%
% :description
%
% Reads in a BrainVoyager VOI file.
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
% 2005.02.25    S Takerkart Added compatibility with Version 2
% 2005.03.18    S Takerkart Added compatibility with Version 3
%               now returns unique set ov VTC coordinates

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

% read File Version
while 1
    textline = fgetl(fid);
    if  size(textline,2)~=0 break, end
end
[myString,voi.FileVersion] = strread(textline,'%s%d');
if ( voi.FileVersion~=1 & voi.FileVersion~=2 & voi.FileVersion~=3 )
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

% extra line in version 3
if ( voi.FileVersion == 3 )
  while 1
    textline = fgetl(fid);
    if  size(textline,2)~=0 break, end
  end
  [myString,voi.SubjectVOINamingConvention] = strread(textline,'%s%s');
end;
  
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
    
    % version 2: read color of VOI
    if ( voi.FileVersion > 1 )
      while 1
        textline = fgetl(fid);
        if  size(textline,4)~=0 break, end
      end
      [myString,R,G,B] = strread(textline, '%s%d%d%d');
      voi.VOIs(this_voi).ColorOfVOI(1) = R;
      voi.VOIs(this_voi).ColorOfVOI(2) = G;
      voi.VOIs(this_voi).ColorOfVOI(3) = B;
    end;
      
    % read number of voxels
    while 1
        textline = fgetl(fid);
        if  size(textline,2)~=0 break, end
    end
    [myString,voi.VOIs(this_voi).NrOfVoxels] = strread(textline,'%s%d');
    disp(fprintf('VOI number %d contains %d voxels',this_voi,voi.VOIs(this_voi).NrOfVoxels));
    
    voi.VOIs(this_voi).coord_vmr = textscan(fid,'%d%d%d', voi.VOIs(this_voi).NrOfVoxels);
 
    x_vtc = (m_ACxTAL - voi.VOIs.coord_vmr{2} - XStartVTC) / ...
            ResolutionVTC + 1;
    y_vtc = (m_ACyTAL - voi.VOIs.coord_vmr{3} - YStartVTC) / ...
            ResolutionVTC + 1;
    z_vtc = (m_ACzTAL - voi.VOIs.coord_vmr{1} - ZStartVTC) / ...
            ResolutionVTC + 1;
    
    vtc_coord = [x_vtc y_vtc z_vtc];

    vtc_unique_coord = unique(floor(vtc_coord),'rows');
    
    voi.VOIs(this_voi).coord_vtc{1} = squeeze(vtc_unique_coord(:,1));
    voi.VOIs(this_voi).coord_vtc{2} = squeeze(vtc_unique_coord(:,2));
    voi.VOIs(this_voi).coord_vtc{3} = squeeze(vtc_unique_coord(:,3));

end;

fclose(fid);


    

