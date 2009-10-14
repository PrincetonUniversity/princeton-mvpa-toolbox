function glm = bv_readglm(fname)
% glm = bv_readglm(fname)
%
% :description
%
% Reads in a version 2 (BrainVoyager 2000 4.4, QX) GLM file.
%
% :inputs
%
% fname             file to read, e.g. 'mymodel.glm'
%
% :outputs
%
% glm               glm structure. List this function to see the field
%                   names.
%
% :history
%
% 2004.04.16	Ben Singer  Edited slightly a version received from Sylvain.
%                           Probably originally written by Jens Schwarzbach
%                           in August 2002.  
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

glm.VersionNumber = fread(fid, 1, 'int16');
if (glm.VersionNumber ~= 2)
    error('Can only read in version 2 files');
end

glm.ProjectType = fread(fid, 1, 'int8');
glm.NrOfTimePoints = fread(fid, 1, 'int32');
glm.NrOfPredictors = fread(fid, 1, 'int32');
glm.NrOfStudies = fread(fid, 1, 'int32');
glm.SeparatePredictors = fread(fid, 1, 'int8');
glm.ZTransform = fread(fid, 1, 'int8');
glm.Resolution = fread(fid, 1, 'int16');
glm.SerialCorrelation = fread(fid, 1, 'int8');
glm.MeanAR1Pre = fread(fid, 1, 'float32');
glm.MeanAR1Post = fread(fid, 1, 'float32');
glm.XStart = fread(fid, 1, 'int16');
glm.XEnd = fread(fid, 1, 'int16');
glm.YStart = fread(fid, 1, 'int16');
glm.YEnd = fread(fid, 1, 'int16');
glm.ZStart = fread(fid, 1, 'int16');
glm.ZEnd = fread(fid, 1, 'int16');
glm.CortexBasedStatistics = fread(fid, 1, 'int8');
glm.NrOfVoxelsForBonfCorrection = fread(fid, 1, 'int32');
glm.CortexBasedStatisticsMaskFile = read_str(fid);

for s = 1:glm.NrOfStudies
  glm.run(s).NrOfTimePts = fread(fid, 1, 'int32');
  glm.run(s).VTC = read_str(fid);
  glm.run(s).RTC = read_str(fid);
end

for p = 1:glm.NrOfPredictors
  glm.predictor(p).name1 = read_str(fid);
  glm.predictor(p).name2 = read_str(fid);
  glm.predictor(p).R = fread(fid, 1, 'int32');
  glm.predictor(p).G = fread(fid, 1, 'int32');
  glm.predictor(p).B = fread(fid, 1, 'int32');
end

SizeDesignMatrix = glm.NrOfTimePoints*glm.NrOfPredictors;
for i = 1:SizeDesignMatrix
  glm.DesignMatrix(i) = fread(fid, 1, 'float32');
end

SizeiXX = glm.NrOfPredictors*glm.NrOfPredictors;
for i = 1:SizeiXX
  glm.iXX(i) = fread(fid, 1, 'float32');
end

DimP = 2*glm.NrOfPredictors + 3 + glm.SerialCorrelation;

if ( glm.ProjectType == 1 )
  DimZ = (glm.ZEnd - glm.ZStart) / glm.Resolution;
  DimY = (glm.YEnd - glm.YStart) / glm.Resolution;
  DimX = (glm.XEnd - glm.XStart) / glm.Resolution;
elseif ( glm.ProjectType == 0 )
  DimZ = glm.YStart;
  DimY = glm.XEnd;
  DimX = glm.XStart;
end;

for p=1:DimP
    glm.data(p).matrix = reshape(fread(fid,DimX*DimY*DimZ,'float32'),DimX,DimY,DimZ);
end;

fclose(fid);
