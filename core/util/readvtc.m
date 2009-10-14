function [tdim,xdim,ydim,zdim,data] = readvtc(filename)

% function [tdim,xdim,ydim,zdim,data] = readvtc(filename)
%
% from from http://ebc.lrdc.pitt.edu/discuss/read.php?4,24
%
% reads in a single volume timecourse (.vtc) file
% input:
% filename: name of vtc file to open
% output:
% xdim: x dimension of .vtc image
% ydim: y dimension of .vtc image
% zdim: z dimension of .vtc image
% tdim: t dimension of .vtc image (number of volumes)
% data: 4d array of size (tdim, xdim, ydim, zdim) containing timecourse
% maureen mchugo, university of pittsburgh

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

fid = fopen(filename, 'r');
version = fread(fid, 1, 'int16');

% read past strings in vtc header
singleChar = 1;
zerocount=0;
while zerocount~=2
  singleChar=fread(fid,1,'uchar');
  if singleChar==0
    zerocount=zerocount+1;
  end
end

tdim = fread(fid, 1, 'int16');
resolution = fread(fid, 1, 'int16');
XStart = fread(fid, 1, 'int16');
XEnd = fread(fid, 1, 'int16');
YStart = fread(fid, 1, 'int16');
YEnd = fread(fid, 1, 'int16');
ZStart = fread(fid, 1, 'int16');
ZEnd = fread(fid, 1, 'int16');

% skip past version 2 info
if (version== 2 )
  v2a=fread(fid,1,'int16');
  v2b=fread(fid,3,'float32');
  v2c = fread(fid, 2, 'int16');
end;

% calculate x,y,z dimensions
xdim = (XEnd - XStart) / resolution;
ydim = (YEnd - YStart) / resolution;
zdim = (ZEnd - ZStart) / resolution;

data=zeros(tdim,xdim,ydim,zdim);

for z=1:zdim
  for y=1:ydim
    for x=1:xdim
      data(:,x,y,z)=fread(fid,tdim,'int16');
    end
  end
end

fclose(fid);



