function vmp = bv_writevmp(fname_out_vmp, data, fname_in_vtc, ...
                                x_vmr, y_vmr, z_vmr)
% vmp = bv_readvmp(fname)
%
% :description
%
% Writes a VMP file in version 2 (BrainVoyager QX).
%
% :inputs
%
% fname_out_vmp     file to be written out, e.g. 'myvolstats.vmp'
% data              3d matrix (of vtc size) to be written
% fname_in_vtc      example vtc with same geometry
% x_vmr             size of vmr in x dimension for visualization
% y_vmr             size of vmr in y dimension for visualization
% z_vmr             size of vmr in z dimension for visualization
%
% :outputs
%
% vmp               the vmp structure that is written
%
% :history
%
% 2005.02.22    Sylvain Takerkart First release

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


vtc = bv_readvtc(fname_in_vtc);



fid_out = platform_fopen(fname_out_vmp,'w');

vmp.VersionNumber = 2;
fwrite(fid_out, vmp.VersionNumber, 'int16');
% intsize for version 2 of vmp file
intSize = 'int32';

% output vmp will only contain one map
vmp.NrOfMaps = 1;
fwrite(fid_out,vmp.NrOfMaps,intSize);
vmp.MapType = 1;
fwrite(fid_out,vmp.MapType,intSize);
vmp.NrOfLags = 0;
fwrite(fid_out,vmp.NrOfLags,intSize);

% arbitrary properties of the map to be displayed
vmp.Map(1).ClusterSize = 50;
fwrite(fid_out,vmp.Map(1).ClusterSize,'int32');
vmp.Map(1).EnableClusterCheck = 0;
fwrite(fid_out,vmp.Map(1).EnableClusterCheck,'int8');
vmp.Map(1).StatThreshCritValue = 1;
fwrite(fid_out,vmp.Map(1).StatThreshCritValue,'float32');
vmp.Map(1).StatColThreshMaxValue = 8;
fwrite(fid_out,vmp.Map(1).StatColThreshMaxValue,'float32');
vmp.Map(1).df = [36 0];
fwrite(fid_out,vmp.Map(1).df(1:2),'int32');
vmp.Map(1).Bonferroni = 54331;
fwrite(fid_out,vmp.Map(1).Bonferroni,'int32');
vmp.Map(1).RGBcrit = [0 0 100]';
fwrite(fid_out,vmp.Map(1).RGBcrit,'uint8');
vmp.Map(1).RGBmax = [0 0 255]';
fwrite(fid_out,vmp.Map(1).RGBmax,'uint8');
vmp.Map(1).EnableSMPColor = 0;
fwrite(fid_out,vmp.Map(1).EnableSMPColor,'uint8');
vmp.Map(1).TransparentColorFactor = 1;
fwrite(fid_out,vmp.Map(1).TransparentColorFactor,'float32');
% need to add a null character at the end of the string
vmp.Map(1).name = char(['<GLM-t>' 0]);
fwrite(fid_out,vmp.Map(1).name,'char');

% sizes of associated files (vtc and vmr)
vmp.VMRDimXYZ = [ int16(x_vmr) int16(y_vmr) int16(z_vmr)]';
fwrite(fid_out,vmp.VMRDimXYZ,intSize);
vmp.XStart = vtc.XStart;
fwrite(fid_out,vmp.XStart,intSize);
vmp.XEnd = vtc.XEnd;
fwrite(fid_out,vmp.XEnd,intSize);
vmp.YStart = vtc.YStart;
fwrite(fid_out,vmp.YStart,intSize);
vmp.YEnd = vtc.YEnd;
fwrite(fid_out,vmp.YEnd,intSize);
vmp.ZStart = vtc.ZStart;
fwrite(fid_out,vmp.ZStart,intSize);
vmp.ZEnd = vtc.ZEnd;
fwrite(fid_out,vmp.ZEnd,intSize);
vmp.Resolution = 1;
fwrite(fid_out,vmp.Resolution,intSize);

vmp_data_dims = [   (vmp.XEnd - vmp.XStart + 1) / vmp.Resolution ...
                    (vmp.YEnd - vmp.YStart + 1) / vmp.Resolution ...
                    (vmp.ZEnd - vmp.ZStart + 1) / vmp.Resolution];

vtc_x_max = size(data,1)+1;
vtc_y_max = size(data,2)+1;
vtc_z_max = size(data,3)+1;

outdata = zeros(vmp.XEnd - vmp.XStart + 1,...
                vmp.YEnd - vmp.YStart + 1,...
                vmp.ZEnd - vmp.ZStart + 1);

for z=1:vmp_data_dims(3)
  for y=1:vmp_data_dims(2)
    for x=1:vmp_data_dims(1)
      vtc_x = floor( x / vtc.Resolution)+1;
      vtc_y = floor( y / vtc.Resolution)+1;
      vtc_z = floor( z / vtc.Resolution)+1;
      if ( vtc_x>0 & vtc_x<vtc_x_max & vtc_y>0 & vtc_y<vtc_y_max ...
           & vtc_z>0 & vtc_z<vtc_z_max)
        outdata(x,y,z) = data(vtc_x, vtc_y, vtc_z);
      else
        outdata(x,y,z)=0;
      end;
    end;
  end;
end;
fwrite(fid_out,outdata,'float32');
vmp.Map(1).data = outdata;

fclose(fid_out);
